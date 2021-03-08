//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Kinds of data to retrieve from system_profiler tool
// Note: there can be more data types depending on the macOS version, use system_profiler -listDataTypes to list all
typedef enum : UInt64
{
    DFSystemProfileData_All                     = 0,
    DFSystemProfileData_AirPort                 = 1L << 0,  // SPAirPortDataType
    DFSystemProfileData_Applications            = 1L << 1,  // SPApplicationsDataType
    DFSystemProfileData_Audio                   = 1L << 2,  // SPAudioDataType
    DFSystemProfileData_Bluetooth               = 1L << 3,  // SPBluetoothDataType
    DFSystemProfileData_Camera                  = 1L << 4,  // SPCameraDataType
    DFSystemProfileData_CardReader              = 1L << 5,  // SPCardReaderDataType
    DFSystemProfileData_Component               = 1L << 6,  // SPComponentDataType
    DFSystemProfileData_ConfigurationProfile    = 1L << 7,  // SPConfigurationProfileDataType
    DFSystemProfileData_DeveloperTools          = 1L << 8,  // SPDeveloperToolsDataType
    DFSystemProfileData_Diagnostics             = 1L << 9,  // SPDiagnosticsDataType
    DFSystemProfileData_DisabledSoftware        = 1L << 10, // SPDisabledSoftwareDataType
    DFSystemProfileData_DiscBurning             = 1L << 11, // SPDiscBurningDataType
    DFSystemProfileData_EthernetCards           = 1L << 12, // SPEthernetDataType
    DFSystemProfileData_Extensions              = 1L << 13, // SPExtensionsDataType
    DFSystemProfileData_Firewall                = 1L << 14, // SPFirewallDataType
    DFSystemProfileData_FireWire                = 1L << 15, // SPFireWireDataType
    DFSystemProfileData_FibreChannel            = 1L << 16, // SPFibreChannelDataType
    DFSystemProfileData_Fonts                   = 1L << 17, // SPFontsDataType
    DFSystemProfileData_Frameworks              = 1L << 18, // SPFrameworksDataType
    DFSystemProfileData_Displays                = 1L << 19, // SPDisplaysDataType
    DFSystemProfileData_Hardware                = 1L << 20, // SPHardwareDataType
    DFSystemProfileData_HardwareRAID            = 1L << 21, // SPHardwareRAIDDataType
    DFSystemProfileData_InstallHistory          = 1L << 22, // SPInstallHistoryDataType
    DFSystemProfileData_Logs                    = 1L << 23, // SPLogsDataType
    DFSystemProfileData_ManagedClient           = 1L << 24, // SPManagedClientDataType
    DFSystemProfileData_Memory                  = 1L << 25, // SPMemoryDataType
    DFSystemProfileData_Network                 = 1L << 26, // SPNetworkDataType
    DFSystemProfileData_NetworkLocations        = 1L << 27, // SPNetworkLocationDataType
    DFSystemProfileData_NetworkVolume           = 1L << 28, // SPNetworkVolumeDataType
    DFSystemProfileData_NVMe                    = 1L << 29, // SPNVMeDataType
    DFSystemProfileData_ParallelATA             = 1L << 30, // SPParallelATADataType
    DFSystemProfileData_ParallelSCSI            = 1L << 31, // SPParallelSCSIDataType
    DFSystemProfileData_PCI                     = 1L << 32, // SPPCIDataType
    DFSystemProfileData_Power                   = 1L << 33, // SPPowerDataType
    DFSystemProfileData_PrefPane                = 1L << 34, // SPPrefPaneDataType
    DFSystemProfileData_PrinterSoftware         = 1L << 35, // SPPrintersSoftwareDataType
    DFSystemProfileData_Printers                = 1L << 36, // SPPrintersDataType
    DFSystemProfileData_SAS                     = 1L << 37, // SPSASDataType
    DFSystemProfileData_SerialATA               = 1L << 38, // SPSerialATADataType
    DFSystemProfileData_Software                = 1L << 39, // SPSoftwareDataType
    DFSystemProfileData_SPI                     = 1L << 40, // SPSPIDataType
    DFSystemProfileData_StartupItem             = 1L << 41, // SPStartupItemDataType
    DFSystemProfileData_Storage                 = 1L << 42, // SPStorageDataType
    DFSystemProfileData_SyncServices            = 1L << 43, // SPSyncServicesDataType
    DFSystemProfileData_Thunderbolt             = 1L << 44, // SPThunderboltDataType
    DFSystemProfileData_UniversalAccess         = 1L << 45, // SPUniversalAccessDataType
    DFSystemProfileData_USB                     = 1L << 46, // SPUSBDataType
    DFSystemProfileData_WWAN                    = 1L << 47, // SPWWANDataType
} DFSystemProfileDataType;









