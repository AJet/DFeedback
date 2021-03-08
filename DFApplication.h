//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Application
@interface DFApplication : NSApplication

// Relaunches the app
- (void)relaunch;

// Flag indicating that an unhandled exception has occured and the app is in process of terminating
@property (nonatomic, readonly) BOOL isPostmortem;

// You can ignore certain exceptions whose stack traces contain the following strings
+ (void)ignoreExceptionsWhoseStackTraceContains:(NSArray*)strings;

@end
