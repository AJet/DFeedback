//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "DFSystemProfileDataType.h"
#import "DFFeedbackSenderDelegate.h"
#import "DFSystemProfileFetcherDelegate.h"

//-------------------------------------------------------------------------------------------------
// Feedback window controller
@interface DFFeedbackWindowController : NSWindowController <DFFeedbackSenderDelegate, DFSystemProfileFetcherDelegate>

// Initialization, call before first use
+ (void)initializeWithFeedbackUrl:(NSString*)feedbackUrl
           systemProfileDataTypes:(DFSystemProfileDataType)systemProfileDataTypes;

// Singleton
+ (DFFeedbackWindowController*)singleton;

// Shows the feedback window on the specified tab
- (void)showGeneralQuestion;

- (void)showBugReport;

- (void)showFeatureRequest;

// default first page
- (void)show;



@end
