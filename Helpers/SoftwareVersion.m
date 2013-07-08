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
        BOOL hasMinor = NO;
		NSUInteger buildVersion = 0;
        BOOL hasBuild = NO;
		int scanned = 0;
		NSScanner* scanner = [NSScanner scannerWithString:parts[0]];
		if ([scanner scanInt:&scanned] && scanned >= 0)
		{
			majorVersion = scanned;
			if (parts.count > 1)
			{
				scanner = [NSScanner scannerWithString:parts[1]];
				if ([scanner scanInt:&scanned] && scanned >= 0)
				{
					minorVersion = scanned;
                    hasMinor = YES;
					if (parts.count > 2)
					{
						scanner = [NSScanner scannerWithString:parts[2]];
						if ([scanner scanInt:&scanned] && scanned >= 0)
						{
							buildVersion = scanned;
                            hasBuild = YES;
						}
					}
				}
			}
			result = [[[SoftwareVersion alloc] init] autorelease];
            result.major = majorVersion;
            result.minor = minorVersion;
            result.hasMinor = hasMinor;
            result.build = buildVersion;
            result.hasBuild = hasBuild;
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

//-------------------------------------------------------------------------------------------------
- (void)makeDisplayName
{
    NSString* displayName = nil;
    if (_hasBuild && _hasMinor)
    {
        displayName = [NSString stringWithFormat:@"%lu.%lu.%lu", _major, _minor, _build];
    }
    else if (_hasMinor)
    {
        displayName = [NSString stringWithFormat:@"%lu.%lu", _major, _minor];
    }
    else
    {
        displayName = [NSString stringWithFormat:@"%lu", _major];
    }
    self.displayName = displayName;
}

@end
