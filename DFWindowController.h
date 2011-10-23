//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Feedback window controller
//-------------------------------------------------------------------------------------------------
@interface DFWindowController : NSWindowController 
//-------------------------------------------------------------------------------------------------
// Initialization, call before first use
+ (void)initializeWithFeedbackURL:(NSString*)feedbackURL;

//-------------------------------------------------------------------------------------------------
// Shows the feedback window on the specified tab
+ (void)showGeneralQuestion;
+ (void)showBugReport;
+ (void)showFeatureRequest;
// default first page
+ (void)show;

@end
