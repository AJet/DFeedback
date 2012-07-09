//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Application
//-------------------------------------------------------------------------------------------------
@interface DFApplication : NSApplication
{
    BOOL _isRelaunching;
    BOOL _isPostmortem;
}

//-------------------------------------------------------------------------------------------------
// Relaunches the app
- (void)relaunch;

//-------------------------------------------------------------------------------------------------
// Flag indicating that an unhandled exception has occured and the app is in process of terminating
- (BOOL)isPostmortem;

@end
