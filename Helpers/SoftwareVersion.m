//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "SoftwareVersion.h"

//-------------------------------------------------------------------------------------------------
typedef enum : NSUInteger
{
    VersionPart_Major = 0,
    VersionPart_Minor = 1,
    VersionPart_Build = 2,
    VersionPart_Count
} VersionPartIndex;

typedef struct
{
    BOOL isSet;
    NSUInteger number;
    NSString* string;
} VersionPart;

//-------------------------------------------------------------------------------------------------
@implementation SoftwareVersion
{
    VersionPart _parts[VersionPart_Count];
}

//-------------------------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	if (self != nil)
	{
        memset(_parts, 0, sizeof(_parts));
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[_displayName release];
    for (VersionPartIndex i = 0; i < VersionPart_Count; ++i)
    {
        [_parts[i].string release];
    }
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
+ (SoftwareVersion*)makeVersionFromString:(NSString*)versionString
{
    SoftwareVersion* result = [[[SoftwareVersion alloc] init] autorelease];
	NSArray* partStrings = [versionString componentsSeparatedByString:@"."];
    VersionPartIndex partCount = MIN(partStrings.count, VersionPart_Count);
    for (VersionPartIndex i = 0; i < partCount; ++i)
    {
        NSString* partString = partStrings[i];
        NSScanner* scanner = [NSScanner scannerWithString:partString];
        VersionPart* part = result.parts + i;
        NSInteger number = 0;
        part->isSet = [scanner scanInteger:&number] && number >= 0;
        if (part->isSet)
        {
            part->number = number;
            if (!scanner.isAtEnd)
            {
                part->string = [[partString substringFromIndex:scanner.scanLocation] retain];
            }
        }
        else
        {
            // invalid format, do not continue
            break;
        }
    }
    // must be at least one valid part
    if (!result.parts[0].isSet)
    {
        result = nil;
    }
    
	return result;
}

//-------------------------------------------------------------------------------------------------
+ (SoftwareVersion*)makeVersionFromNumbers:(const NSUInteger*)numbers
                                     count:(NSUInteger)count
{
    SoftwareVersion* result = nil;
    if (count > 0)
    {
        result = [[[SoftwareVersion alloc] init] autorelease];
        VersionPartIndex partCount = MIN(count, VersionPart_Count);
        for (VersionPartIndex i = 0; i < partCount; ++i)
        {
            VersionPart* part = result.parts + i;
            part->isSet = YES;
            part->number = numbers[i];
        }
    }
    return result;
}

//-------------------------------------------------------------------------------------------------
- (NSComparisonResult)compare:(SoftwareVersion*)other
{
    if (other == nil)
    {
        return NSOrderedDescending;
    }
    for (VersionPartIndex i = 0; i < VersionPart_Count; ++i)
    {
        VersionPart* selfPart = _parts + i;
        VersionPart* otherPart = other.parts + i;
        // compare presense
        if (!selfPart->isSet && otherPart->isSet)
        {
            return NSOrderedAscending;
        }
        if (selfPart->isSet && !otherPart->isSet)
        {
            return NSOrderedDescending;
        }
        if (selfPart->isSet && otherPart->isSet)
        {
            // compare numbers
            if (selfPart->number < otherPart->number)
            {
                return NSOrderedAscending;
            }
            if (selfPart->number > otherPart->number)
            {
                return NSOrderedDescending;
            }
            // compare strings
            // string (like b, rc) is earlier than without string
            if (selfPart->string.length == 0 && otherPart->string.length > 0)
            {
                return NSOrderedDescending;
            }
            if (selfPart->string.length > 0 && otherPart->string.length == 0)
            {
                return NSOrderedAscending;
            }
            if (selfPart->string.length > 0 && otherPart->string.length > 0)
            {
                NSComparisonResult stringResult = [selfPart->string compare:otherPart->string];
                // continue if strings are the same
                if (stringResult != NSOrderedSame)
                {
                    return stringResult;
                }
            }
        }
    }
	return NSOrderedSame;
}

//-------------------------------------------------------------------------------------------------
- (NSString*)displayNameUpToPart:(VersionPartIndex)partIndex
{
    NSString* displayName = nil;
    for (VersionPartIndex i = 0; i <= partIndex; ++i)
    {
        VersionPart* part = _parts + i;
        if (part->isSet)
        {
            if (i == 0)
            {
                displayName = @"";
            }
            else
            {
                displayName = [displayName stringByAppendingString:@"."];
            }
            displayName = [displayName stringByAppendingFormat:@"%lu", part->number];
            if (part->string != nil)
            {
                displayName = [displayName stringByAppendingFormat:@"%@", part->string];
            }
        }
        else
        {
            break;
        }
    }
    return displayName;
}

//-------------------------------------------------------------------------------------------------
- (NSString*)displayNameUpToMinor
{
    return [self displayNameUpToPart:VersionPart_Minor];
}

//-------------------------------------------------------------------------------------------------
- (void)makeDisplayName
{
    NSString* displayName = [self displayNameUpToPart:VersionPart_Count - 1];
    self.displayName = displayName;
}


//-------------------------------------------------------------------------------------------------
- (VersionPart*)parts
{
    return _parts;
}

//-------------------------------------------------------------------------------------------------
- (NSUInteger)majorNumber
{
    return _parts[VersionPart_Major].number;
}

//-------------------------------------------------------------------------------------------------
- (NSUInteger)minorNumber
{
    return _parts[VersionPart_Minor].number;
}

//-------------------------------------------------------------------------------------------------
- (NSUInteger)buildNumber
{
    return _parts[VersionPart_Build].number;
}

@end
