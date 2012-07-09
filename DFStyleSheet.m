//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFStyleSheet.h"

//-------------------------------------------------------------------------------------------------
// Private static data
//-------------------------------------------------------------------------------------------------
static BOOL _isInitialized = NO;

//-------------------------------------------------------------------------------------------------
// Bounce icon
CGFloat			DFBounceIcon_bounceFactor = 1.5;
NSTimeInterval	DFBounceIcon_bounceHalfDuration = 0.15;
NSTimeInterval	DFBounceIcon_fadeDuration = 0.25;
static void		initializeDFBounceIconStyles(void)
{
	// do nothing
}

//-------------------------------------------------------------------------------------------------
// Placeholder text view
NSDictionary*	DFPlaceholderTextView_placeholderTextAttributes = nil;
static void		initializeDFPlaceholderTextViewStyles(void)
{
	DFPlaceholderTextView_placeholderTextAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithDeviceRed:128.0/255.0 green:128.0/255.0 blue:145.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
														[NSFont userFontOfSize:12], NSFontAttributeName,
														nil] retain];
}

//-------------------------------------------------------------------------------------------------
// Feedback window
CGFloat			DFFeedbackWindow_bottomBarHeight = 45.0;
NSImage*		DFFeedbackWindow_emailWarningImage = nil;
static void		initializeDFFeedbackWindow(void)
{
	DFFeedbackWindow_emailWarningImage = [[NSImage imageNamed:@"DFWarningIcon"] retain];
}

//-------------------------------------------------------------------------------------------------
// Crash report window
CGFloat         DFCrashReportWindow_bottomBarHeight = 45.0;
static void		initializeDFCrashReportWindow(void)
{
    // do nothing
}


//-------------------------------------------------------------------------------------------------
void initializeDFStyles(void)
{
	if (!_isInitialized)
	{
		// bounce icon view
		initializeDFBounceIconStyles();
	
		// placeholder text view
		initializeDFPlaceholderTextViewStyles();
	
		// feedback window
		initializeDFFeedbackWindow();

        // crash report window
		initializeDFCrashReportWindow();

		// save state
		_isInitialized = YES;
	}
}


