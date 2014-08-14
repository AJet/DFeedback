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
		SoftwareVersion *version = [self version];
		
		if (version.majorNumber == 10)
		{
			if (version.minorNumber >= 9)
			{
				_generation = OSXGeneration_Mavericks;
			}
			else if (version.minorNumber >= 8)
			{
				_generation = OSXGeneration_MountainLion;
			}
			else if (version.minorNumber >= 7)
			{
				_generation = OSXGeneration_Lion;
			}
			else if (version.minorNumber >= 6)
			{
				_generation = OSXGeneration_SnowLeopard;
			}
			else if (version.minorNumber >= 5)
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
		NSDictionary * dict = [[[NSDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] autorelease];
        NSString *productVersion = [dict valueForKey:@"ProductVersion"];
		NSArray *components = [[productVersion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"."];
		NSUInteger numbers[components.count];
		for (NSUInteger componentIndex = 0; componentIndex < components.count; componentIndex++) {
			NSString *component = components[componentIndex];
			long long number;
			NSScanner *scanner = [NSScanner scannerWithString:component];
			if (![scanner scanLongLong:&number]) {
				number = 0;
			}
			numbers[componentIndex] = number;
		}
		
        _version = [[SoftwareVersion versionFromNumbers:numbers count:components.count] retain];
        [_version makeDisplayName];
    }
    return _version;
}


@end
