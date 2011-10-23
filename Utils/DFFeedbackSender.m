//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFFeedbackSender.h"
#import "NSURLRequest+Extension.h"

//-------------------------------------------------------------------------------------------------
@implementation DFFeedbackSender
//-------------------------------------------------------------------------------------------------
{
	id m_target;
	SEL m_action;
	bool m_isCanceled;
	NSURLConnection* m_connection;
}

//-------------------------------------------------------------------------------------------------
- (id)initWithCallbackTarget:(id)target action:(SEL)action
{
	self = [super init];
	if (self)
	{
		m_target = target;
		m_action = action;
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[m_connection release];
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
	m_connection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
}

//-------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	if (!m_isCanceled)
	{
		[m_target performSelectorOnMainThread:m_action withObject:error waitUntilDone:NO];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection*)connection 
{
	if (!m_isCanceled)
	{
		[m_target performSelectorOnMainThread:m_action withObject:nil waitUntilDone:NO];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)cancel
{
	m_isCanceled = true;
}

@end
