//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Kinds of data to retrieve from system profile
typedef enum : UInt64
{
    DFSystemProfileData_None = 0,
    DFSystemProfileData_Audio = 1L << 0,
    DFSystemProfileData_Bluetooth = 1L << 1,
    DFSystemProfileData_CardReader = 1L << 2,
    DFSystemProfileData_Diagnostics = 1L << 3,
    DFSystemProfileData_DiscBurning = 1L << 4,
    DFSystemProfileData_EthernetCards = 1L << 5,
    DFSystemProfileData_FireWire = 1L << 6,
    DFSystemProfileData_GraphicsDisplays = 1L << 7,
    DFSystemProfileData_Hardware = 1L << 8,
    DFSystemProfileData_Memory = 1L << 9,
    DFSystemProfileData_Network = 1L << 10,
    DFSystemProfileData_PrinterSoftware = 1L << 11,
    DFSystemProfileData_Printers = 1L << 12,
    DFSystemProfileData_SerialATA = 1L << 13,
    DFSystemProfileData_Software = 1L << 14,
    DFSystemProfileData_Thunderbolt = 1L << 15,
    DFSystemProfileData_USB = 1L << 16,
    DFSystemProfileData_WiFi = 1L << 17,
    DFSystemProfileData_All = 0xFFFFFFFFFFFFFFFF,
    
} DFSystemProfileDataType;


