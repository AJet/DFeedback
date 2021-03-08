//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFStyleSheet.h"
#import "LiteralHelpers.h"

//-------------------------------------------------------------------------------------------------
static BOOL _isInitialized = NO;

//-------------------------------------------------------------------------------------------------
// Bounce icon
NSTimeInterval	DFBounceIcon_animationDuration = .25;
static void		InitializeDFBounceIconStyles(void)
{
	// do nothing
}

//-------------------------------------------------------------------------------------------------
// Placeholder text view
NSDictionary*	DFPlaceholderTextView_placeholderTextAttributes = nil;
static void		InitializeDFPlaceholderTextViewStyles(void)
{
    DFPlaceholderTextView_placeholderTextAttributes = [NSDictionaryWithKeysAndValues(NSForegroundColorAttributeName, [NSColor colorWithDeviceRed:128./255. green:128./255. blue:145./255. alpha:1.],
                                                                                     NSFontAttributeName, [NSFont userFontOfSize:12],
                                                                                     nil) retain];
}

//-------------------------------------------------------------------------------------------------
// Feedback window
CGFloat			DFFeedbackWindow_bottomBarHeight = 45.;
NSImage*		DFFeedbackWindow_emailWarningImage = nil;
CGFloat         DFFeedbackWindow_emailWarningImageZoomIncrement = 20.;
static void		InitializeDFFeedbackWindow(void)
{
	DFFeedbackWindow_emailWarningImage = [[NSImage imageNamed:@"DFWarning"] retain];
}

//-------------------------------------------------------------------------------------------------
// Crash report window
CGFloat         DFCrashReportWindow_bottomBarHeight = 45.;
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


