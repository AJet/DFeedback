//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "OSVersionChecker.h"

//-------------------------------------------------------------------------------------------------
// Private static data
//-------------------------------------------------------------------------------------------------
static OSVersion _version = 0;

//-------------------------------------------------------------------------------------------------
@implementation OSVersionChecker
//-------------------------------------------------------------------------------------------------
{
    
}

//-------------------------------------------------------------------------------------------------
+ (OSVersion)macOsVersion
{
	if (_version == OSVersion_Unknown)
	{
		SInt32 macVersion = 0;
		if (Gestalt(gestaltSystemVersion, &macVersion) == noErr)
		{
			if (macVersion >= 0x1070)
			{
				_version = OSVersion_Lion;
			}
			else if (macVersion >= 0x1060)
			{
				_version = OSVersion_SnowLeopard;
			}
			else if (macVersion >= 0x1050)
			{
				_version = OSVersion_Leopard;
			}
		}	
	}
	return _version;
}

@end
