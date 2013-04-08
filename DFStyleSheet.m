//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFStyleSheet.h"

//-------------------------------------------------------------------------------------------------
static BOOL _isInitialized = NO;

//-------------------------------------------------------------------------------------------------
// Bounce icon
CGFloat			DFBounceIcon_bounceFactor = 1.5;
NSTimeInterval	DFBounceIcon_bounceHalfDuration = 0.15;
NSTimeInterval	DFBounceIcon_fadeDuration = 0.25;
static void		InitializeDFBounceIconStyles(void)
{
	// do nothing
}

//-------------------------------------------------------------------------------------------------
// Placeholder text view
NSDictionary*	DFPlaceholderTextView_placeholderTextAttributes = nil;
static void		InitializeDFPlaceholderTextViewStyles(void)
{
	DFPlaceholderTextView_placeholderTextAttributes = [@{NSForegroundColorAttributeName: [NSColor colorWithDeviceRed:128.0/255.0 green:128.0/255.0 blue:145.0/255.0 alpha:1.0],
														NSFontAttributeName: [NSFont userFontOfSize:12]} retain];
}

//-------------------------------------------------------------------------------------------------
// Feedback window
CGFloat			DFFeedbackWindow_bottomBarHeight = 45.0;
NSImage*		DFFeedbackWindow_emailWarningImage = nil;
static void		InitializeDFFeedbackWindow(void)
{
	DFFeedbackWindow_emailWarningImage = [[NSImage imageNamed:@"DFWarning"] retain];
}

//-------------------------------------------------------------------------------------------------
// Crash report window
CGFloat         DFCrashReportWindow_bottomBarHeight = 45.0;
static void		InitializeDFCrashReportWindow(void)
{
    // do nothing
}


//-------------------------------------------------------------------------------------------------
void InitializeDFStyles(void)
{
	if (!_isInitialized)
	{
		// bounce icon view
		InitializeDFBounceIconStyles();
	
		// placeholder text view
		InitializeDFPlaceholderTextViewStyles();
	
		// feedback window
		InitializeDFFeedbackWindow();

        // crash report window
		InitializeDFCrashReportWindow();

		// save state
		_isInitialized = YES;
	}
}


