//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class SoftwareVersion;

//-------------------------------------------------------------------------------------------------
typedef enum OSXGeneration : NSUInteger
{
    OSXGeneration_Unknown = 0,
    OSXGeneration_Leopard = 0x1050,
    OSXGeneration_SnowLeopard = 0x1060,
    OSXGeneration_Lion = 0x1070,
    OSXGeneration_MountainLion = 0x1080,
    OSXGeneration_Mavericks = 0x1090,
    OSXGeneration_Yosemite = 0x10A0,
} OSXGeneration;

//-------------------------------------------------------------------------------------------------
// OSX version
@interface OSXVersion : NSObject

// Gets OSX generation
+ (OSXGeneration)generation;

// Gets full OSX version
+ (SoftwareVersion*)version;

@end
