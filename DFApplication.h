//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Application
@interface DFApplication : NSApplication

// Relaunches the app
- (void)relaunch;

// Flag indicating that an unhandled exception has occured and the app is in process of terminating
@property (nonatomic, readonly) BOOL isPostmortem;

@end
