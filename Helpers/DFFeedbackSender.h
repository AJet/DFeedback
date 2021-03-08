//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@protocol DFFeedbackSenderDelegate;

//-------------------------------------------------------------------------------------------------
// Encapsulates asynchronous feedback sending
@interface DFFeedbackSender : NSObject

// Delegate
@property (nonatomic, assign) id<DFFeedbackSenderDelegate> delegate;

// Begins sending feedback, completes asynchronously
- (void)sendFeedbackToUrl:(NSString*)url
			 feedbackText:(NSString*)feedbackText 
			 feedbackType:(NSString*)feedbackType
			systemProfile:(NSString*)systemProfile
				userEmail:(NSString*)userEmail;

// Cancels pending request
- (void)cancel;

@end
