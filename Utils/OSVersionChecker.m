//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "OSVersionChecker.h"

//-------------------------------------------------------------------------------------------------
// Private static data
//-------------------------------------------------------------------------------------------------
static OSVersion s_version = 0;

//-------------------------------------------------------------------------------------------------
@implementation OSVersionChecker
//-------------------------------------------------------------------------------------------------
{
    
}

//-------------------------------------------------------------------------------------------------
+ (OSVersion)macOsVersion
{
	if (s_version == OSVersion_Unknown)
	{
		SInt32 macVersion = 0;
		if (Gestalt(gestaltSystemVersion, &macVersion) == noErr)
		{
			if (macVersion >= 0x1070)
			{
				s_version = OSVersion_Lion;
			}
			else if (macVersion >= 0x1060)
			{
				s_version = OSVersion_SnowLeopard;
			}
			else if (macVersion >= 0x1050)
			{
				s_version = OSVersion_Leopard;
			}
		}	
	}
	return s_version;
}

@end
