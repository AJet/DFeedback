//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DemoAppDelegate.h"
#import "DFFeedbackWindowController.h"
#import "DFCrashReportWindowController.h"

//-------------------------------------------------------------------------------------------------
@implementation DemoAppDelegate
//-------------------------------------------------------------------------------------------------
@synthesize window;

//-------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification*)notification 
{
	// TODO: insert your feedback URL here
    NSString* feedbackURL = @"";
	[DFFeedbackWindowController initializeWithFeedbackURL:feedbackURL]; 
    // TODO: insert your icon here
    [DFCrashReportWindowController initializeWithFeedbackURL:feedbackURL icon:[NSApp applicationIconImage]];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)application
{
    return YES;
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendGeneralQuestion:(id)sender
{
	[DFFeedbackWindowController showGeneralQuestion];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendBugReport:(id)sender
{
	[DFFeedbackWindowController showBugReport];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendFeatureRequest:(id)sender
{
	[DFFeedbackWindowController showFeatureRequest];
}

//-------------------------------------------------------------------------------------------------
- (void)crashThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSAssert(false, @"Test crash in a separate thread");
    
    [pool release];
    
    [NSThread exit];
}

//-------------------------------------------------------------------------------------------------
- (void)testCrashInThread:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(crashThread) toTarget:self withObject:nil];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)testCrash:(id)sender
{
    NSAssert(false, @"Test Crash");
}

@end
