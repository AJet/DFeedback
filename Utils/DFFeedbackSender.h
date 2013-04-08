//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Encapsulates asynchronous feedback sending
@interface DFFeedbackSender : NSObject

// Initializer
- (id)initWithCompletionBlock:(void (^)(NSError* error))completionBlock;

// Begins sending feedback, completes asynchronously
- (void)sendFeedbackToUrl:(NSString*)url
			 feedbackText:(NSString*)feedbackText 
			 feedbackType:(NSString*)feedbackType
			systemProfile:(NSString*)systemProfile
				userEmail:(NSString*)userEmail;

// Cancels pending request
- (void)cancel;

@end
