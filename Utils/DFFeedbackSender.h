//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Encapsulates asynchronous feedback sending
//-------------------------------------------------------------------------------------------------
@interface DFFeedbackSender : NSObject 
{
	id m_target;
	SEL m_action;
	bool m_isCanceled;
	NSURLConnection* m_connection;
}

//-------------------------------------------------------------------------------------------------
// Initializers
//-------------------------------------------------------------------------------------------------
- (id)initWithCallbackTarget:(id)target action:(SEL)action;

//-------------------------------------------------------------------------------------------------
// Public methods
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
