//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DemoAppDelegate.h"
#import "DFFeedbackWindowController.h"
#import "DFCrashReportWindowController.h"

//-------------------------------------------------------------------------------------------------
@interface DemoAppDelegate()

@property (assign) IBOutlet NSWindow* window;

@end

//-------------------------------------------------------------------------------------------------
@implementation DemoAppDelegate

//-------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification*)notification 
{
	// TODO: insert your feedback URL here
    NSString* feedbackUrl = @"";
    NSString* updateUrl = @"";
	[DFFeedbackWindowController initializeWithFeedbackUrl:feedbackUrl
                                   systemProfileDataTypes:DFSystemProfileData_All];
    // TODO: insert your icon here
    [DFCrashReportWindowController initializeWithFeedbackUrl:feedbackUrl
                                                   updateUrl:updateUrl
                                                        icon:[NSApp applicationIconImage]
                                      systemProfileDataTypes:DFSystemProfileData_All];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)application
{
    return YES;
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendGeneralQuestion:(id)sender
{
	[[DFFeedbackWindowController singleton] showGeneralQuestion];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendBugReport:(id)sender
{
	[[DFFeedbackWindowController singleton] showBugReport];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendFeatureRequest:(id)sender
{
	[[DFFeedbackWindowController singleton] showFeatureRequest];
}

//-------------------------------------------------------------------------------------------------
- (void)crashThread:(BOOL)isGCD
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSAssert(false, @"Test crash in a separate %@ thread", isGCD ? @"GCD" : @"NS");
    
    [pool release];
    
    [NSThread exit];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)testCrashInNSThread:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(crashThread:) toTarget:self withObject:(id)NO];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)testCrashInGCDThread:(id)sender
{
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue,
                   ^{
                       [self crashThread:YES];
                   });
}

//-------------------------------------------------------------------------------------------------
- (IBAction)testCrash:(id)sender
{
    NSAssert(false, @"Test Crash");
}

@end
