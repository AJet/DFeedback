//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFApplication.h"
#import "DFCrashReportWindowController.h"
#import "GTMStackTrace.h"

//-------------------------------------------------------------------------------------------------
static NSString* const kUserDefaultCrashSequenceCount = @"DFApplication_crashSequenceCount";
static NSUInteger const kCrashSequenceCountMax = 3;

//-------------------------------------------------------------------------------------------------
@implementation DFApplication
{
    BOOL _isRelaunching;
    BOOL _isPostmortem;
}

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

    // NOTE: it seems to sometimes not work, at least it fails sometimes on 10.8 in sandboxed mode
    
    // launch a script that waits for the app to exit and then relaunches it
    NSString* scriptPath = [[NSBundle mainBundle] pathForResource:@"DFRelaunch" ofType:@"sh"];
    NSString* bundlePath = [NSString stringWithFormat:@"%s", [NSBundle mainBundle].executablePath.fileSystemRepresentation];
    NSString* processIdentifier = [NSString stringWithFormat:@"%d", [NSProcessInfo processInfo].processIdentifier];
    NSString* bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSArray* arguments = @[scriptPath,
                           bundlePath,
                           processIdentifier,
                           bundleId];
    NSTask* task = [[[NSTask alloc] init] autorelease];
    task.launchPath = @"/bin/bash";
    task.arguments = arguments;
    [task launch];
}

//-------------------------------------------------------------------------------------------------
- (void)relaunch
{
    
	// prevent endless loop of relaunch and crash
	NSUInteger crashSequenceCount = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultCrashSequenceCount];
    if (crashSequenceCount < kCrashSequenceCountMax - 1)
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
		NSUInteger crashSequenceCount = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultCrashSequenceCount];
        ++crashSequenceCount;
        [[NSUserDefaults standardUserDefaults] setInteger:crashSequenceCount 
                                                   forKey:kUserDefaultCrashSequenceCount];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
	}
	// normal termination
	else
	{
        // reset crash counter
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultCrashSequenceCount];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	// do terminate
	[super terminate:self];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)shouldIgnoreException:(NSException*)exception
          exceptionStackTrace:(NSString*)exceptionStackTrace
{
    BOOL result = NO;
	NSString* exceptionName = exception.name;
	
    // accessibility exceptions are a normal mode of operation, should be ignored
	BOOL isAccessibilityException = [exceptionName isEqualToString:NSAccessibilityException];
    if (isAccessibilityException)
    {
        result = YES;
    }
    else
    {
        // Sparkle Update bugs should be ignored
        BOOL isSparkleException = [exceptionStackTrace rangeOfString:@"Versions/A/Sparkle"].location != NSNotFound;
        if (isSparkleException)
        {
            result = YES;
        }
        else
        {
            // Simble exceptions should be ignored
            BOOL isSimbleException = [exceptionStackTrace rangeOfString:@"SIMBL"].location != NSNotFound;
            if (isSimbleException)
            {
                result = YES;
            }
            else
            {
                // Mars Themes exception
                BOOL isMarsThemesException = [exceptionStackTrace rangeOfString:@"MTTextTools"].location != NSNotFound;
                if (isMarsThemesException)
                {
                    result = YES;
                }
            }
        }
	}
    
	return result;
}

//-------------------------------------------------------------------------------------------------
- (void)reportExceptionInMainThread:(NSException*)exception
                exceptionStackTrace:(NSString*)exceptionStackTrace
{
    @try
    {
        if (!_isPostmortem)
        {
            // prevent endless loop
            _isPostmortem = YES;
            
            NSLog(@"Reporting exception: %@", exception.reason);
            
            // hide all windows
            for (NSWindow* window in [NSApp windows])
            {
                [window orderOut:self];
            }
            
            // show problem report window
            [[DFCrashReportWindowController singleton] showReportForException:exception
                                                          exceptionStackTrace:exceptionStackTrace];
        }
    }
    @catch (NSException* fatalException)
    {
        // the exception occurred during exception handling - considered fatal
        NSLog(@"Fatal error:%@\nwhile processing exception: %@", fatalException.reason, exception.reason);
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

    NSString* exceptionStackTrace = GTMStackTraceFromException(exception);
    
	if (![self shouldIgnoreException:exception
                 exceptionStackTrace:exceptionStackTrace])
    {
        // main thread
        if ([NSThread currentThread] == [NSThread mainThread])
        {
            [self reportExceptionInMainThread:exception
                          exceptionStackTrace:exceptionStackTrace];
        }
        // not main thread
        else
        {
            // handle on main thread
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self reportExceptionInMainThread:exception
                                             exceptionStackTrace:exceptionStackTrace];
                           });
            // exit immediately, or will crash the app
            // TODO: this causes a crash with signal if the thread is from GCD, not a pthread
            [NSThread exit];
        }
    }
}

@end
