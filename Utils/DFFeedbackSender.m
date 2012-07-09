//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFFeedbackSender.h"
#import "NSURLRequest+Extension.h"

//-------------------------------------------------------------------------------------------------
@implementation DFFeedbackSender
//-------------------------------------------------------------------------------------------------
- (id)initWithCallbackTarget:(id)target action:(SEL)action
{
	self = [super init];
	if (self != nil)
	{
		_target = target;
		_action = action;
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[_connection release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)sendFeedbackToURL:(NSString*)url
			 feedbackText:(NSString*)feedbackText 
			 feedbackType:(NSString*)feedbackType
			systemProfile:(NSString*)systemProfile
				userEmail:(NSString*)userEmail
				 
{
	// create dictionary of fields to be transmitted using http POST
    NSDictionary* form = [NSDictionary dictionaryWithObjectsAndKeys:
						  feedbackType, @"feedbackType",
                          feedbackText, @"feedback",
                          userEmail != nil ? userEmail : @"<email suppressed>", @"email",
                          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"], @"appName",
                          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], @"bundleID",
                          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], @"version",
                          systemProfile != nil ? systemProfile : @"<system profile suppressed>", @"systemProfile",
                          nil];
	// create request
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] postForm:form];
	// begin sending the data
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSModalPanelRunLoopMode];
    [_connection start];
}

//-------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	if (!_isCanceled)
	{
		[_target performSelectorOnMainThread:_action withObject:error waitUntilDone:NO];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection*)connection 
{
	if (!_isCanceled)
	{
		[_target performSelectorOnMainThread:_action withObject:nil waitUntilDone:NO];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)cancel
{
	_isCanceled = YES;
}

@end
