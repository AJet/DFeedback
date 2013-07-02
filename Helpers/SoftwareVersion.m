//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "SoftwareVersion.h"


//-------------------------------------------------------------------------------------------------
@implementation SoftwareVersion

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
	[_displayName release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
+ (SoftwareVersion*)versionFromString:(NSString*)versionString
{
    SoftwareVersion* result = nil;
	NSArray* parts = [versionString componentsSeparatedByString:@"."];
	if (parts.count > 0)
	{
		NSUInteger majorVersion = 0;
		NSUInteger minorVersion = 0;
		NSUInteger buildVersion = 0;
		int scanned = 0;
		NSScanner* scanner = [NSScanner scannerWithString:parts[0]];
		if ([scanner scanInt:&scanned] && scanned >= 0)
		{
			majorVersion = scanned;
			if (parts.count > 1)
			{
				scanner = [NSScanner scannerWithString:parts[1]];
				if ([scanner scanInt:&scanned] && scanned > 0)
				{
					minorVersion = scanned;
					if (parts.count > 2)
					{
						scanner = [NSScanner scannerWithString:parts[2]];
						if ([scanner scanInt:&scanned] && scanned > 0)
						{
							buildVersion = scanned;
						}
					}
				}
			}
			result = [[[SoftwareVersion alloc] init] autorelease];
            result.major = majorVersion;
            result.minor = minorVersion;
            result.build = buildVersion;
		}
	}
	return result;
}

//-------------------------------------------------------------------------------------------------
- (NSComparisonResult)compare:(SoftwareVersion*)other
{
	if (_major < other.major)
	{
		return NSOrderedAscending;
	}
	if (_major > other.major)
	{
		return NSOrderedDescending;
	}
	if (_minor < other.minor)
	{
		return NSOrderedAscending;
	}
	if (_minor > other.minor)
	{
		return NSOrderedDescending;
	}
	if (_build < other.build)
	{
		return NSOrderedAscending;
	}
	if (_build > other.build)
	{
		return NSOrderedDescending;
	}
	return NSOrderedSame;
}


@end
