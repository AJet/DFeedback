//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Encapsulates asynchronous feedback sending
//-------------------------------------------------------------------------------------------------
@interface DFFeedbackSender : NSObject 
//-------------------------------------------------------------------------------------------------
{
	id _target;
	SEL _action;
	BOOL _isCanceled;
	NSURLConnection* _connection;
}

//-------------------------------------------------------------------------------------------------
// Initializers
- (id)initWithCallbackTarget:(id)target action:(SEL)action;

//-------------------------------------------------------------------------------------------------
// Begins sending feedback, completes asynchronously
- (void)sendFeedbackToURL:(NSString*)url
			 feedbackText:(NSString*)feedbackText 
			 feedbackType:(NSString*)feedbackType
			systemProfile:(NSString*)systemProfile
				userEmail:(NSString*)userEmail;

//-------------------------------------------------------------------------------------------------
// Cancels pending request
- (void)cancel;

@end
