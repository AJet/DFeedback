//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Encapsulates asynchronous fetching of system profile
//-------------------------------------------------------------------------------------------------
@interface DFSystemProfileFetcher : NSObject 
//-------------------------------------------------------------------------------------------------
{
	id m_target;
	SEL m_action;
	NSTask* m_scriptTask;
	NSPipe* m_scriptPipe;
	NSString* m_profile;
	bool m_isDoneFetching;
}

//-------------------------------------------------------------------------------------------------
// Initializer
- (id)initWithCallbackTarget:(id)target action:(SEL)action;

//-------------------------------------------------------------------------------------------------
// Begins fetching system profile, completes asynchronously
- (void)fetch;

//-------------------------------------------------------------------------------------------------
// Cancels a pending request
- (void)cancel;

//-------------------------------------------------------------------------------------------------
// Resulting profile
- (NSString*)profile;

//-------------------------------------------------------------------------------------------------
// Is done fetching flag
- (bool)isDoneFetching;

@end
