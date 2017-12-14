//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFSystemProfileFetcher.h"
#import "DFSystemProfileFetcherDelegate.h"
#import "OSXVersion.h"
#import "ApplicationSandboxInfo.h"

//-------------------------------------------------------------------------------------------------
static NSString* kDataTypeIDs[] =
{
    @"SPAirPortDataType",
    @"SPApplicationsDataType",
    @"SPAudioDataType",
    @"SPBluetoothDataType",
    @"SPCameraDataType",
    @"SPCardReaderDataType",
    @"SPComponentDataType",
    @"SPConfigurationProfileDataType",
    @"SPDeveloperToolsDataType",
    @"SPDiagnosticsDataType",
    @"SPDisabledSoftwareDataType",
    @"SPDiscBurningDataType",
    @"SPEthernetDataType",
    @"SPExtensionsDataType",
    @"SPFirewallDataType",
    @"SPFireWireDataType",
    @"SPFibreChannelDataType",
    @"SPFontsDataType",
    @"SPFrameworksDataType",
    @"SPDisplaysDataType",
    @"SPHardwareDataType",
    @"SPHardwareRAIDDataType",
    @"SPInstallHistoryDataType",
    @"SPLogsDataType",
    @"SPManagedClientDataType",
    @"SPMemoryDataType",
    @"SPNetworkDataType",
    @"SPNetworkLocationDataType",
    @"SPNetworkVolumeDataType",
    @"SPNVMeDataType",
    @"SPParallelATADataType",
    @"SPParallelSCSIDataType",
    @"SPPCIDataType",
    @"SPPowerDataType",
    @"SPPrefPaneDataType",
    @"SPPrintersSoftwareDataType",
    @"SPPrintersDataType",
    @"SPSASDataType",
    @"SPSerialATADataType",
    @"SPSoftwareDataType",
    @"SPSPIDataType",
    @"SPStartupItemDataType",
    @"SPStorageDataType",
    @"SPSyncServicesDataType",
    @"SPThunderboltDataType",
    @"SPUniversalAccessDataType",
    @"SPUSBDataType",
    @"SPWWANDataType"
};

static const DFSystemProfileDataType kDataTypes[] =
{
    DFSystemProfileData_AirPort,
    DFSystemProfileData_Applications,
    DFSystemProfileData_Audio,
    DFSystemProfileData_Bluetooth,
    DFSystemProfileData_Camera,
    DFSystemProfileData_CardReader,
    DFSystemProfileData_Component,
    DFSystemProfileData_ConfigurationProfile,
    DFSystemProfileData_DeveloperTools,
    DFSystemProfileData_Diagnostics,
    DFSystemProfileData_DisabledSoftware,
    DFSystemProfileData_DiscBurning,
    DFSystemProfileData_EthernetCards,
    DFSystemProfileData_Extensions,
    DFSystemProfileData_Firewall,
    DFSystemProfileData_FireWire,
    DFSystemProfileData_FibreChannel,
    DFSystemProfileData_Fonts,
    DFSystemProfileData_Frameworks,
    DFSystemProfileData_Displays,
    DFSystemProfileData_Hardware,
    DFSystemProfileData_HardwareRAID,
    DFSystemProfileData_InstallHistory,
    DFSystemProfileData_Logs,
    DFSystemProfileData_ManagedClient,
    DFSystemProfileData_Memory,
    DFSystemProfileData_Network,
    DFSystemProfileData_NetworkLocations,
    DFSystemProfileData_NetworkVolume,
    DFSystemProfileData_NVMe,
    DFSystemProfileData_ParallelATA,
    DFSystemProfileData_ParallelSCSI,
    DFSystemProfileData_PCI,
    DFSystemProfileData_Power,
    DFSystemProfileData_PrefPane,
    DFSystemProfileData_PrinterSoftware,
    DFSystemProfileData_Printers,
    DFSystemProfileData_SAS,
    DFSystemProfileData_SerialATA,
    DFSystemProfileData_Software,
    DFSystemProfileData_SPI,
    DFSystemProfileData_StartupItem,
    DFSystemProfileData_Storage,
    DFSystemProfileData_SyncServices,
    DFSystemProfileData_Thunderbolt,
    DFSystemProfileData_UniversalAccess,
    DFSystemProfileData_USB,
    DFSystemProfileData_WWAN
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
    NSAssert(sizeof(kDataTypeIDs) / sizeof(kDataTypeIDs[0]) == sizeof(kDataTypes) / sizeof(kDataTypes[0]), @"The number of data types doesn't match the number of data type ids.");
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
            NSString* newProfile = [NSString stringWithUTF8String:data.bytes];
			_profile = [newProfile retain];
		}
	}
	_isDoneFetching = YES;
    
    [self.delegate systemProfileFetcherDidFinish:self];
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

        NSMutableArray* arguments = [NSMutableArray array];
        if (dataTypes != DFSystemProfileData_All)
        {
            for (NSUInteger i = 0; i < sizeof(kDataTypeIDs) / sizeof(kDataTypeIDs[0]); ++i)
            {
                DFSystemProfileDataType currDataType = kDataTypes[i];
                if ((currDataType & dataTypes) != 0)
                {
                    [arguments addObject:kDataTypeIDs[i]];
                }
            }
        }
        [arguments addObject:@"-detailLevel"];
        [arguments addObject:@"mini"];
        
        _scriptTask.arguments = arguments;
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

