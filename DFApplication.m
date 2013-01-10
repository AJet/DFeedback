//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFApplication.h"
#import "DFCrashReportWindowController.h"

//-------------------------------------------------------------------------------------------------
// Private constants
//-------------------------------------------------------------------------------------------------
static NSString* const USER_DEFAULT_CRASH_SEQUENCE_COUNT = @"DFApplication_crashSequenceCount";
static const NSUInteger CRASH_SEQUENCE_COUNT_MAX = 3;

//-------------------------------------------------------------------------------------------------
@implementation DFApplication
//-------------------------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	if (self != nil)
	{
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)launchAnotherInstanceAndWaitForTermination
{
    _isRelaunching = YES;
    
	// launch a script that waits for the app to exit and then relaunches it
	NSString* scriptPath = [[NSBundle mainBundle] pathForResource:@"DFRelaunch" ofType:@"sh"];
	NSString* bundlePath = [NSString stringWithFormat:@"%s", [[[NSBundle mainBundle] executablePath] fileSystemRepresentation]];
	NSString* processIdentifier = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
	NSArray* arguments = @[scriptPath,
						  bundlePath,
						  processIdentifier];
	NSTask* task = [[[NSTask alloc] init] autorelease];
	[task setLaunchPath:@"/bin/bash"];
	[task setArguments:arguments];
	[task launch];
}

//-------------------------------------------------------------------------------------------------
- (void)relaunch
{
	// prevent endless loop of relaunch and crash
	NSUInteger crashSequenceCount = [[NSUserDefaults standardUserDefaults] integerForKey:USER_DEFAULT_CRASH_SEQUENCE_COUNT];
	if (crashSequenceCount < CRASH_SEQUENCE_COUNT_MAX - 1)
	{
		[self launchAnotherInstanceAndWaitForTermination];
	}
	[self terminate:self];
}

//-------------------------------------------------------------------------------------------------
- (void)terminate:(id)sender
{
	// abnormal termination
	if (_isPostmortem && _isRelaunching)
	{
        // save sequential crash count
		NSUInteger crashSequenceCount = [[NSUserDefaults standardUserDefaults] integerForKey:USER_DEFAULT_CRASH_SEQUENCE_COUNT];
        ++crashSequenceCount;
        [[NSUserDefaults standardUserDefaults] setInteger:crashSequenceCount 
                                                   forKey:USER_DEFAULT_CRASH_SEQUENCE_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
	}
	// normal termination
	else
	{
        // reset crash counter
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_CRASH_SEQUENCE_COUNT];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	// do terminate
	[super terminate:self];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)shouldIgnoreException:(NSException*)exception
{   
	NSString* exceptionName = [exception name];
	NSString* exceptionMessage = [exception reason];
	
    // accessibility exceptions are a normal mode of operation, should be ignored
	BOOL isAccessibilityException = [exceptionName isEqualToString:NSAccessibilityException];
	
    // Sparkle Update bugs should be ignored
	BOOL isSparkleException = [exceptionMessage rangeOfString:@"SUUpdater"].location != NSNotFound
    || [exceptionMessage rangeOfString:@"SUHost"].location != NSNotFound
    || [exceptionMessage rangeOfString:@"SUBasicUpdateDriver"].location != NSNotFound;
    
    // Simble exceptions should be ignored
	BOOL isSimbleException = [exceptionMessage rangeOfString:@"SIMBL"].location != NSNotFound;
	
	return isAccessibilityException || isSparkleException || isSimbleException;
}

//-------------------------------------------------------------------------------------------------
- (void)reportExceptionInMainThread:(NSException*)exception
{
    @try
    {
        if (!_isPostmortem)
        {
            // prevent endless loop
            _isPostmortem = YES;
            
            NSLog(@"Reporting exception: %@", [exception reason]);
            
            // hide all windows
            for (NSWindow* window in [NSApp windows])
            {
                [window orderOut:self];
            }
            
            // show problem report window
            [[DFCrashReportWindowController singleton] showReportForException:exception];
        }
    }
    @catch (NSException* fatalException)
    {
        // the exception occurred during exception handling - considered fatal
        NSLog(@"Fatal error while processing exception: %@", [exception reason]);
        @try
        {
            [(DFApplication*)NSApp relaunch];
        }
        @catch (NSException* exception)
        {
            // absorb silently
        }
    }
}

//-------------------------------------------------------------------------------------------------
- (void)reportException:(NSException*)exception
{
    [super reportException:exception];

	if (![self shouldIgnoreException:exception])
    {
        // main thread
        if ([NSThread currentThread] == [NSThread mainThread])
        {
            [self reportExceptionInMainThread:exception];
        }
        // not main thread
        else
        {
            // handle on main thread
            [self performSelectorOnMainThread:@selector(reportExceptionInMainThread:) withObject:exception waitUntilDone:NO];
            // exit immediately, or will crash the app
            [NSThread exit];
        }
    }
}

//-------------------------------------------------------------------------------------------------
- (BOOL)isPostmortem
{
    return _isPostmortem;
}

@end
