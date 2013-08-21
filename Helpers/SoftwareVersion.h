//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Encapsulates software version parsing and comparison
@interface SoftwareVersion : NSObject

// Parses string and creates version
+ (SoftwareVersion*)versionFromString:(NSString*)versionString;

// Creates version from an array of numbers
+ (SoftwareVersion*)versionFromNumbers:(const NSUInteger*)numbers
                                 count:(NSUInteger)count;

// Comparator
- (NSComparisonResult)compare:(SoftwareVersion*)other;

// Display name saved
@property (nonatomic, retain) NSString* displayName;

// Display name generated
- (void)makeDisplayName;

// Access to particular numbers
@property (nonatomic, readonly) NSUInteger majorNumber;
@property (nonatomic, readonly) NSUInteger minorNumber;
@property (nonatomic, readonly) NSUInteger buildNumber;

@end
