//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "OSXVersion.h"
#import "SoftwareVersion.h"

//-------------------------------------------------------------------------------------------------
static OSXGeneration _generation = OSXGeneration_Unknown;
static SoftwareVersion* _version = nil;

//-------------------------------------------------------------------------------------------------
@implementation OSXVersion

//-------------------------------------------------------------------------------------------------
+ (OSXGeneration)generation;
{
	if (_generation == OSXGeneration_Unknown)
	{
        OSXGeneration result = _generation;

        SInt32 majorVersion = 0;
        SInt32 minorVersion = 0;
        BOOL hasVersion = NO;
        
        // pre-yosemite deprecated way
#if __MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10
        if (Gestalt(gestaltSystemVersionMajor, &majorVersion) == noErr)
        {
            if (Gestalt(gestaltSystemVersionMinor, &minorVersion) == noErr)
            {
                hasVersion = YES;
            }
        }
#else
        NSOperatingSystemVersion version = NSProcessInfo.processInfo.operatingSystemVersion;
        majorVersion = (SInt32)version.majorVersion;
        minorVersion = (SInt32)version.minorVersion;
        hasVersion = YES;
        
#endif
        if (hasVersion)
        {
            if (majorVersion == 10)
            {
                switch (minorVersion)
                {
                    case 12:
                        result = OSXGeneration_Sierra;
                        break;
                    case 11:
                        result = OSXGeneration_ElCapitan;
                        break;
                    case 10:
                        result = OSXGeneration_Yosemite;
                        break;
                    case 9:
                        result = OSXGeneration_Mavericks;
                        break;
                    case 8:
                        result = OSXGeneration_MountainLion;
                        break;
                    case 7:
                        result = OSXGeneration_Lion;
                        break;
                    case 6:
                        result = OSXGeneration_SnowLeopard;
                        break;
                    case 5:
                        result = OSXGeneration_Leopard;
                        break;
                        
                    default:
                        break;
                }
            }
            
            if (result == OSXGeneration_Unknown)
            {
                // an attempt to provide future compatibility
                if (majorVersion >= 0 && majorVersion <= 0xFF && minorVersion >= 0 && minorVersion <= 0xFF)
                {
                    result = (OSXGeneration)((majorVersion << 8) | minorVersion);
                }
            }
        }
        
        _generation = result;
	}
	return _generation;
}

//-------------------------------------------------------------------------------------------------
+ (SoftwareVersion*)version
{
    if (_version == nil)
    {
        SInt32 majorVersion = 0;
        SInt32 minorVersion = 0;
        SInt32 buildVersion = 0;
        BOOL hasVersion = NO;

#if __MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10
        if (Gestalt(gestaltSystemVersionMajor, &majorVersion) == noErr)
        {
            if (Gestalt(gestaltSystemVersionMinor, &minorVersion) == noErr)
            {
                if (Gestalt(gestaltSystemVersionBugFix, &buildVersion) == noErr)
                {
                    hasVersion = YES;
                }
            }
        }
#else
        NSOperatingSystemVersion version = NSProcessInfo.processInfo.operatingSystemVersion;
        majorVersion = (SInt32)version.majorVersion;
        minorVersion = (SInt32)version.minorVersion;
        buildVersion = (SInt32)version.patchVersion;
        hasVersion = YES;

#endif
        
        if (hasVersion)
        {
            NSUInteger numbers[3] = {(NSUInteger)majorVersion, (NSUInteger)minorVersion, (NSUInteger)buildVersion};
            _version = [[SoftwareVersion makeVersionFromNumbers:numbers count:3] retain];
            [_version makeDisplayName];
        }
    }
    
    return _version;
}


@end
