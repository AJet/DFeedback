//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
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
        SInt32 majorVersion = 0;
        if (Gestalt(gestaltSystemVersionMajor, &majorVersion) == noErr)
        {
            if (majorVersion == 10)
            {
                SInt32 minorVersion = 0;
                if (Gestalt(gestaltSystemVersionMinor, &minorVersion) == noErr)
                {
                    switch (minorVersion)
                    {
                        case 11:
                            _generation = OSXGeneration_ElCapitan;
                            break;
                        case 10:
                            _generation = OSXGeneration_Yosemite;
                            break;
                        case 9:
                            _generation = OSXGeneration_Mavericks;
                            break;
                        case 8:
                            _generation = OSXGeneration_MountainLion;
                            break;
                        case 7:
                            _generation = OSXGeneration_Lion;
                            break;
                        case 6:
                            _generation = OSXGeneration_SnowLeopard;
                            break;
                        case 5:
                            _generation = OSXGeneration_Leopard;
                            break;
                            
                        default:
                            break;
                    }
                }
            }
        }
	}
	return _generation;
}

//-------------------------------------------------------------------------------------------------
+ (SoftwareVersion*)version
{
    if (_version == nil)
    {
        SInt32 majorVersion = 0;
        if (Gestalt(gestaltSystemVersionMajor, &majorVersion) == noErr)
        {
            SInt32 minorVersion = 0;
            if (Gestalt(gestaltSystemVersionMinor, &minorVersion) == noErr)
            {
                SInt32 buildVersion = 0;
                if (Gestalt(gestaltSystemVersionBugFix, &buildVersion) == noErr)
                {
                    NSUInteger numbers[3] = {(NSUInteger)majorVersion, (NSUInteger)minorVersion, (NSUInteger)buildVersion};
                    _version = [[SoftwareVersion makeVersionFromNumbers:numbers count:3] retain];
                    [_version makeDisplayName];
                }
            }
        }
    }
    return _version;
}


@end
