//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class DFFeedbackSender;

//-------------------------------------------------------------------------------------------------
// Feedback sender delegate
@protocol DFFeedbackSenderDelegate

// Completion, with or without error
- (void)feedbackSender:(DFFeedbackSender*)sender didFinishWithError:(NSError*)error;

@end
