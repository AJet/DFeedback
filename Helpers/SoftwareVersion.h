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

// Comparator
- (NSComparisonResult)compare:(SoftwareVersion*)other;

// Fields
@property (nonatomic, retain) NSString* displayName;
- (void)makeDisplayName;

@property (nonatomic) NSUInteger major;

@property (nonatomic) NSUInteger minor;
@property (nonatomic) BOOL hasMinor;

@property (nonatomic) NSUInteger build;
@property (nonatomic) BOOL hasBuild;

@end
