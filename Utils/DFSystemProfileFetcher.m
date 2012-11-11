//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFSystemProfileFetcher.h"

//-------------------------------------------------------------------------------------------------
@implementation DFSystemProfileFetcher
//-------------------------------------------------------------------------------------------------
- (id)initWithCallbackTarget:(id)target action:(SEL)action
{
	self = [super init];
	if (self != nil)
	{
		_target = target;
		_action = action;
 		_scriptPipe = [[NSPipe pipe] retain];
		_scriptTask = [[NSTask alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scriptPipeDidComplete:)
													 name:NSFileHandleReadToEndOfFileCompletionNotification
												   object:[_scriptPipe fileHandleForReading]];	
		
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSFileHandleReadToEndOfFileCompletionNotification
												  object:[_scriptPipe fileHandleForReading]];	
	[_scriptTask release];
	[_scriptPipe release];
	[_profile release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)scriptPipeDidComplete:(NSNotification*)notification 
{
	if (notification != nil)
	{
		NSData* data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
		if (data)
		{
			[_profile release];
			_profile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		}
	}
	_isDoneFetching = YES;
	[_target performSelector:_action withObject:self];
}

//-------------------------------------------------------------------------------------------------
- (void)fetch
{
    BOOL success = NO;
    NSString* failureReason = nil;
	_isDoneFetching = NO;
	[_scriptTask setLaunchPath:@"/usr/sbin/system_profiler"];
	[_scriptTask setArguments:@[@"-detailLevel", @"mini"]];
	[_scriptTask setStandardOutput:_scriptPipe];
	@try
	{
		[_scriptTask launch];
        NSFileHandle* handle = [_scriptPipe fileHandleForReading];
        if (handle == nil)
        {
            failureReason = @"Invalid file handle";
        }
        else
        {
            [handle readToEndOfFileInBackgroundAndNotifyForModes:@[NSDefaultRunLoopMode,
                                                                  NSModalPanelRunLoopMode]];
            success = YES;
        }
	}
	@catch (NSException* exception)
	{
        failureReason = [exception reason];
	}
    
    if (!success)
    {
        NSLog(@"Failed to fetch system profile: %@", failureReason);
        // emulate async completion
        [self scriptPipeDidComplete:nil];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)cancel
{
	[_scriptTask terminate];
}

//-------------------------------------------------------------------------------------------------
- (NSString*)profile
{
	return _profile;
}

//-------------------------------------------------------------------------------------------------
- (BOOL)isDoneFetching
{
	return _isDoneFetching;
}

@end

