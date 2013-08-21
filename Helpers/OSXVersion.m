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
		SInt32 version = 0;
		if (Gestalt(gestaltSystemVersion, &version) == noErr)
		{
			if (version >= 0x1090)
			{
				_generation = OSXGeneration_Mavericks;
			}
			else if (version >= 0x1080)
			{
				_generation = OSXGeneration_MountainLion;
			}
			else if (version >= 0x1070)
			{
				_generation = OSXGeneration_Lion;
			}
			else if (version >= 0x1060)
			{
				_generation = OSXGeneration_SnowLeopard;
			}
			else if (version >= 0x1050)
			{
				_generation = OSXGeneration_Leopard;
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
        Gestalt(gestaltSystemVersionMajor, &majorVersion);
        SInt32 minorVersion = 0;
        Gestalt(gestaltSystemVersionMinor, &minorVersion);
        SInt32 buildVersion = 0;
        Gestalt(gestaltSystemVersionBugFix, &buildVersion);

        NSUInteger numbers[3] = {majorVersion, minorVersion, buildVersion};
        _version = [[SoftwareVersion versionFromNumbers:numbers count:3] retain];
        [_version makeDisplayName];
    }
    return _version;
}


@end
