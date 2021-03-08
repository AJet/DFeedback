//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class SoftwareVersion;

//-------------------------------------------------------------------------------------------------
typedef enum OSXGeneration : NSUInteger
{
    OSXGeneration_Unknown = 0,
    OSXGeneration_Leopard = 0x0A05,
    OSXGeneration_SnowLeopard = 0x0A06,
    OSXGeneration_Lion = 0x0A07,
    OSXGeneration_MountainLion = 0x0A08,
    OSXGeneration_Mavericks = 0x0A09,
    OSXGeneration_Yosemite = 0x0A0A,
    OSXGeneration_ElCapitan = 0x0A0B,
    OSXGeneration_Sierra = 0x0A0C,
} OSXGeneration;

//-------------------------------------------------------------------------------------------------
// OSX version
@interface OSXVersion : NSObject

// Gets OSX generation
+ (OSXGeneration)generation;

// Gets full OSX version
+ (SoftwareVersion*)version;

@end
