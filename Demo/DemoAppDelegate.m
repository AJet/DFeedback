//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DemoAppDelegate.h"
#import "DFWindowController.h"

//-------------------------------------------------------------------------------------------------
@implementation DemoAppDelegate
//-------------------------------------------------------------------------------------------------
@synthesize window;

//-------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	// TODO: insert your feedback URL here
	[DFWindowController initializeWithFeedbackURL:@""]; 
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendGeneralQuestion:(id)sender
{
	[DFWindowController showGeneralQuestion];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendBugReport:(id)sender
{
	[DFWindowController showBugReport];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendFeatureRequest:(id)sender
{
	[DFWindowController showFeatureRequest];
}

@end
