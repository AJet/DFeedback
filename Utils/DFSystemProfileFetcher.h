//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Encapsulates asynchronous fetching of system profile
//-------------------------------------------------------------------------------------------------
@interface DFSystemProfileFetcher : NSObject 
//-------------------------------------------------------------------------------------------------
{
	id _target;
	SEL _action;
	NSTask* _scriptTask;
	NSPipe* _scriptPipe;
	NSString* _profile;
	BOOL _isDoneFetching;
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
- (BOOL)isDoneFetching;

@end
