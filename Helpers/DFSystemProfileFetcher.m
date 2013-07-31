//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFSystemProfileFetcher.h"
#import "DFSystemProfileFetcherDelegate.h"
#import "OSXVersion.h"
#import "ApplicationSandboxInfo.h"

//-------------------------------------------------------------------------------------------------
static const char* const kSectionHeaders[] =
{
    "Audio:",
    "Bluetooth:",
    "Card Reader:",
    "Diagnostics:",
    "Disc Burning:",
    "Ethernet Cards:",
    "FireWire:",
    "Graphics/Displays:",
    "Hardware:",
    "Memory:",
    "Network:",
    "Printer Software:",
    "Printers:",
    "Serial-ATA:",
    "Software:",
    "Thunderbolt:",
    "USB:",
    "Wi-Fi:"
};

static const DFSystemProfileDataType kSectionTypes[] =
{
    DFSystemProfileData_Audio,
    DFSystemProfileData_Bluetooth,
    DFSystemProfileData_CardReader,
    DFSystemProfileData_Diagnostics,
    DFSystemProfileData_DiscBurning,
    DFSystemProfileData_EthernetCards,
    DFSystemProfileData_FireWire,
    DFSystemProfileData_GraphicsDisplays,
    DFSystemProfileData_Hardware,
    DFSystemProfileData_Memory,
    DFSystemProfileData_Network,
    DFSystemProfileData_PrinterSoftware,
    DFSystemProfileData_Printers,
    DFSystemProfileData_SerialATA,
    DFSystemProfileData_Software,
    DFSystemProfileData_Thunderbolt,
    DFSystemProfileData_USB,
    DFSystemProfileData_WiFi
};

//-------------------------------------------------------------------------------------------------
@implementation DFSystemProfileFetcher
{
	NSTask* _scriptTask;
	NSPipe* _scriptPipe;
	NSString* _profile;
	BOOL _isDoneFetching;
    DFSystemProfileDataType _dataTypes;
}

//-------------------------------------------------------------------------------------------------
+ (void)initialize
{
    NSAssert(sizeof(kSectionHeaders) / sizeof(kSectionHeaders[0]) == sizeof(kSectionTypes) / sizeof(kSectionTypes[0]), @"The number of section headers doesn't match the number of section types.");
}

//-------------------------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	if (self != nil)
	{
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSFileHandleReadToEndOfFileCompletionNotification
												  object:_scriptPipe.fileHandleForReading];
	[_scriptTask release];
	[_scriptPipe release];
	[_profile release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)scriptPipeDidComplete:(NSNotification*)notification 
{
	if (notification != nil)
	{
		NSData* data = notification.userInfo[NSFileHandleNotificationDataItem];
		if (data != nil)
		{
			[_profile release];
			_profile = [[self filteredProfileFromData:data dataTypes:_dataTypes] retain];
		}
	}
	_isDoneFetching = YES;
    
    [self.delegate systemProfileFetcherDidFinish:self];
}

//-------------------------------------------------------------------------------------------------
- (NSString*)filteredProfileFromData:(NSData*)data
                           dataTypes:(DFSystemProfileDataType)dataTypes
{
    NSMutableString* profile = [NSMutableString string];
    
    const char* endOfString = (const char*)data.bytes + data.length;
    char* currLine = (char*)data.bytes;
    BOOL isCurrLineSectionHeader = YES;
    BOOL isSectionIncluded = YES;
    // cycle of characters
    for (char* cp = (char*)data.bytes; cp <= endOfString; ++cp)
    {
        // detect end of line
        if (*cp == '\n' || cp == endOfString)
        {
            // analyze line if not empty
            NSUInteger currLineLength = cp - currLine;
            if (currLineLength > 0)
            {
                // this is a section header
                if (isCurrLineSectionHeader)
                {
                    for (NSUInteger i = 0; i < sizeof(kSectionHeaders) / sizeof(kSectionHeaders[0]); ++i)
                    {
                        if (strncmp(currLine, kSectionHeaders[i], strlen(kSectionHeaders[i])) == 0)
                        {
                            isSectionIncluded = (kSectionTypes[i] & _dataTypes) != 0;
                            break;
                        }
                    }
                }
            }
            // include the line
            if (isSectionIncluded)
            {
                NSString* currLineString = [[[NSString alloc] initWithBytes:currLine length:currLineLength encoding:NSUTF8StringEncoding] autorelease];
                [profile appendString:currLineString];
                [profile appendString:@"\n"];
            }
            
            // new line
            currLine = cp + 1;
            isCurrLineSectionHeader = YES;
        }
        else
        {
            // detect section header
            if (cp == currLine)
            {
                if (*cp == ' ')
                {
                    isCurrLineSectionHeader = NO;
                }
            }
        }
    }

    return profile;
}

//-------------------------------------------------------------------------------------------------
- (void)fetchDataTypes:(DFSystemProfileDataType)dataTypes
{
    BOOL success = NO;
    _dataTypes = dataTypes;
	_isDoneFetching = NO;
    NSString* failureReason = nil;
    if (!self.class.canFetch)
    {
        failureReason = @"Cannot fetch system profile on OSX 10.7.x in sandboxed mode";
    }
    else
    {
        _scriptPipe = [[NSPipe pipe] retain];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scriptPipeDidComplete:)
													 name:NSFileHandleReadToEndOfFileCompletionNotification
												   object:_scriptPipe.fileHandleForReading];
		
        _scriptTask = [[NSTask alloc] init];
        _scriptTask.launchPath = @"/usr/sbin/system_profiler";
        _scriptTask.arguments = @[@"-detailLevel", @"mini"];
        _scriptTask.standardOutput = _scriptPipe;
        @try
        {
            [_scriptTask launch];
            NSFileHandle* handle = _scriptPipe.fileHandleForReading;
            if (handle == nil)
            {
                failureReason = @"Invalid file handle";
            }
            else
            {
                [handle readToEndOfFileInBackgroundAndNotifyForModes:@[NSDefaultRunLoopMode,
                 NSModalPanelRunLoopMode]];
                success = YES;
            }
        }
        @catch (NSException* exception)
        {
            failureReason = exception.reason;
        }
    }
    
    if (!success)
    {
        NSLog(@"Failed to fetch system profile: %@", failureReason);
        // emulate async completion
        [self scriptPipeDidComplete:nil];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)cancel
{
	[_scriptTask terminate];
}

//-------------------------------------------------------------------------------------------------
+ (BOOL)canFetch
{
    BOOL result = YES;
    // on 10.8, system profile seems to work somehow, even in sandbox, but not on 10.7 in sandbox
    if ([OSXVersion generation] < OSXGeneration_MountainLion)
    {
        if ([ApplicationSandboxInfo isSandboxed])
        {
            // currently, this would require a temporary exception entitlement, don't rely on it
            // maybe later implement it using xpc then check the corresponding entitlement here
            result = NO;
        }
    }
    return result;
}

@end

