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
// Link label
NSFont*         DFLinkLabel_font = nil;
NSColor*        DFLinkLabel_normalColor = nil;
NSColor*        DFLinkLabel_linkColor = nil;
BOOL            DFLinkLabel_linkUnderlined = YES;
static void		InitializeDFLinkLabel(void)
{
    DFLinkLabel_font = [[NSFont systemFontOfSize:12.] retain];
    DFLinkLabel_normalColor = [[NSColor colorWithDeviceRed:0. green:0. blue:0. alpha:1.] retain];
    DFLinkLabel_linkColor = [[NSColor colorWithDeviceRed:0. green:0. blue:1. alpha:1.] retain];
}


//-------------------------------------------------------------------------------------------------
void InitializeDFStyles(void)
{
	if (!_isInitialized)
	{
		InitializeDFBounceIconStyles();
	
		InitializeDFPlaceholderTextViewStyles();
	
		InitializeDFFeedbackWindow();

		InitializeDFCrashReportWindow();

        InitializeDFLinkLabel();
        
		_isInitialized = YES;
	}
}


