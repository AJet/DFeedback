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
		m_target = target;
		m_action = action;
 		m_scriptPipe = [[NSPipe pipe] retain];
		m_scriptTask = [[NSTask alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scriptPipeDidComplete:)
													 name:NSFileHandleReadToEndOfFileCompletionNotification
												   object:[m_scriptPipe fileHandleForReading]];	
		
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSFileHandleReadToEndOfFileCompletionNotification
												  object:[m_scriptPipe fileHandleForReading]];	
	[m_scriptTask release];
	[m_scriptPipe release];
	[m_profile release];
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
			[m_profile release];
			m_profile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		}
	}
	m_isDoneFetching = true;
	[m_target performSelector:m_action withObject:self];
}

//-------------------------------------------------------------------------------------------------
- (void)fetch
{
	m_isDoneFetching = false;
	[m_scriptTask setLaunchPath:@"/usr/sbin/system_profiler"];
	[m_scriptTask setArguments:[NSArray arrayWithObjects:@"-detailLevel", @"mini", nil]];
	[m_scriptTask setStandardOutput:m_scriptPipe];
	@try
	{
		[m_scriptTask launch];
		[[m_scriptPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotifyForModes:[NSArray arrayWithObjects:
                                                                                           NSDefaultRunLoopMode, 
                                                                                           NSModalPanelRunLoopMode,
                                                                                           nil]];
	}
	@catch (NSException* exception)
	{
		NSLog(@"Failed to fetch system profile: %@", [exception reason]);
		// emulate async completion
		[self scriptPipeDidComplete:nil];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)cancel
{
	[m_scriptTask terminate];
}

//-------------------------------------------------------------------------------------------------
- (NSString*)profile
{
	return m_profile;
}

//-------------------------------------------------------------------------------------------------
- (bool)isDoneFetching
{
	return m_isDoneFetching;
}

@end

