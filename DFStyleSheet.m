//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFStyleSheet.h"

//-------------------------------------------------------------------------------------------------
// Private static data
//-------------------------------------------------------------------------------------------------
static bool s_isInitialized = false;

//-------------------------------------------------------------------------------------------------
// Bounce icon
CGFloat			DFBounceIcon_bounceFactor = 1.5;
NSTimeInterval	DFBounceIcon_bounceHalfDuration = 0.15;
NSTimeInterval	DFBounceIcon_fadeDuration = 0.25;
void			initializeDFBounceIconStyles()
{
	// do nothing
}

//-------------------------------------------------------------------------------------------------
// Placeholder text view
NSDictionary*	DFPlaceholderTextView_placeholderTextAttributes = nil;
void			initializeDFPlaceholderTextViewStyles()
{
	DFPlaceholderTextView_placeholderTextAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithDeviceRed:128.0/255.0 green:128.0/255.0 blue:145.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
														[NSFont systemFontOfSize:12], NSFontAttributeName,
														nil] retain];
}

//-------------------------------------------------------------------------------------------------
// Window
CGFloat			DFWindow_bottomBarHeight = 45.0;
NSImage*		DFWindow_emailWarningImage = nil;
void			initializeDFFeedbackWindow()
{
	DFWindow_emailWarningImage = [[NSImage imageNamed:@"DFWarningIcon"] retain];
}

//-------------------------------------------------------------------------------------------------
void initializeDFStyles()
{
	if (!s_isInitialized)
	{
		// bounce icon view
		initializeDFBounceIconStyles();
	
		// placeholder text view
		initializeDFPlaceholderTextViewStyles();
	
		// window
		initializeDFFeedbackWindow();
		
		// save state
		s_isInitialized = true;
	}
}


