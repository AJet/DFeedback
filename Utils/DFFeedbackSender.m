//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFFeedbackSender.h"
#import "NSURLRequest+Extension.h"

//-------------------------------------------------------------------------------------------------
@implementation DFFeedbackSender
{
	BOOL _isCanceled;
	NSURLConnection* _connection;
    void (^_completionBlock)(NSError* error);
}

//-------------------------------------------------------------------------------------------------
- (id)initWithCompletionBlock:(void (^)(NSError* error))completionBlock
{
	self = [super init];
	if (self != nil)
	{
        _completionBlock = [completionBlock copy];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_completionBlock release];
	[_connection release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)sendFeedbackToUrl:(NSString*)url
			 feedbackText:(NSString*)feedbackText 
			 feedbackType:(NSString*)feedbackType
			systemProfile:(NSString*)systemProfile
				userEmail:(NSString*)userEmail
				 
{
	// create dictionary of fields to be transmitted using http POST
    NSDictionary* form = @{@"feedbackType": feedbackType,
                          @"feedback": feedbackText,
                          @"email": userEmail != nil ? userEmail : @"<email suppressed>",
                          @"appName": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
                          @"bundleID": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"],
                          @"version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                          @"systemProfile": systemProfile != nil ? systemProfile : @"<system profile suppressed>"};
	// create request
    NSURLRequest* request = [NSURLRequest requestWithUrl:[NSURL URLWithString:url] postForm:form];
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
        if (_completionBlock != nil)
        {
            _completionBlock(error);
        }
	}
}

//-------------------------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection*)connection 
{
	if (!_isCanceled)
	{
        if (_completionBlock != nil)
        {
            _completionBlock(nil);
        }
	}
}

//-------------------------------------------------------------------------------------------------
- (void)cancel
{
	_isCanceled = YES;
}

@end
