//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Security/Security.h>
#import <Security/SecRequirement.h>
#import "DFApplicationSandboxInfo.h"

//-------------------------------------------------------------------------------------------------
static NSString* const ENTITLEMENT_SANDBOX = @"com.apple.security.app-sandbox";
static NSString* const ENTITLEMENT_ADDRESSBOOK_DATA = @"com.apple.security.personal-information.addressbook";


//-------------------------------------------------------------------------------------------------
static DFApplicationSandboxInfo* _singleton = nil;

//-------------------------------------------------------------------------------------------------
@implementation DFApplicationSandboxInfo
//-------------------------------------------------------------------------------------------------
+ (DFApplicationSandboxInfo*)singleton
{
    if (_singleton == nil)
    {
        _singleton = [[DFApplicationSandboxInfo alloc] initWithBundleURL:[[NSBundle mainBundle] bundleURL]];
    }
    return _singleton;
}

//-------------------------------------------------------------------------------------------------
- (id)initWithBundleURL:(NSURL*)bundleURL
{
    self = [super init];
    if (self != nil)
    {
        _bundleURL = [bundleURL retain];
        _queriedEntitlements = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_bundleURL release];
    [_queriedEntitlements release];
    [super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)hasEntitlements:(NSArray*)entitlementCodes
{
    BOOL result = YES;
    
    // filter those codes that have already been queried
    NSMutableArray* newEntitlementCodes = [NSMutableArray arrayWithCapacity:[entitlementCodes count]];
    for (NSString* entitlementCode in entitlementCodes)
    {
        NSNumber* entitlementValue = [_queriedEntitlements objectForKey:entitlementCode];
        if (entitlementValue == nil)
        {
            [newEntitlementCodes addObject:entitlementCode];
        }
        else
        {
            // if at least one entitlement failed, the entire result failed
            if (![entitlementValue boolValue])
            {
                result = NO;
                break;
            }
        }
    }
    
    if (result)
    {
        // query new codes
        for (NSString* entitlementCode in newEntitlementCodes)
        {
            BOOL entitlementResult = NO;
            // create static code object for the bundle
            SecStaticCodeRef bundleStaticCode = NULL;
            SecStaticCodeCreateWithPath((CFURLRef)_bundleURL, kSecCSDefaultFlags, &bundleStaticCode);
            if (bundleStaticCode != NULL)
            {
                // create requirement
                NSString* requirementString = [NSString stringWithFormat:@"entitlement[\"%@\"] exists", entitlementCode];
                SecRequirementRef entitlementRequirement = NULL;
                SecRequirementCreateWithString((CFStringRef)requirementString, kSecCSDefaultFlags, &entitlementRequirement);
                if (entitlementRequirement != NULL)
                {
                    // validate code signature and at the same time check requirement
                    OSStatus signatureValidationResult = SecStaticCodeCheckValidityWithErrors(bundleStaticCode, kSecCSBasicValidateOnly, entitlementRequirement, NULL);
                    if (signatureValidationResult == errSecSuccess)
                    {
                        entitlementResult = YES;
                    }
                    CFRelease(entitlementRequirement);
                }
                CFRelease(bundleStaticCode);
            }
            // save result
            [_queriedEntitlements setObject:[NSNumber numberWithBool:entitlementResult] forKey:entitlementCode];
            
            // if at least one entitlement failed, the entire result failed
            if (!entitlementResult)
            {
                result = NO;
                break;
            }
        }
    }

    return result;
}

//-------------------------------------------------------------------------------------------------
+ (BOOL)hasAddressBookDataEntitlement
{
    return [[self singleton] hasEntitlements:[NSArray arrayWithObjects:ENTITLEMENT_SANDBOX, ENTITLEMENT_ADDRESSBOOK_DATA, nil]];
}

//-------------------------------------------------------------------------------------------------
+ (BOOL)isSandboxed
{
    return [[self singleton] hasEntitlements:[NSArray arrayWithObject:ENTITLEMENT_SANDBOX]];
}


@end
