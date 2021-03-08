//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Customizable style constants that define some appearance and behavior properties of all elements

// Bounce icon
extern NSTimeInterval	DFBounceIcon_animationDuration;

// Placeholder text view
extern NSDictionary*	DFPlaceholderTextView_placeholderTextAttributes;

// Feedback window
extern CGFloat			DFFeedbackWindow_bottomBarHeight;
extern NSImage*			DFFeedbackWindow_emailWarningImage;
extern CGFloat          DFFeedbackWindow_emailWarningImageZoomIncrement;

// Crash report window
extern CGFloat          DFCrashReportWindow_bottomBarHeight;

// Link label
extern NSFont*          DFLinkLabel_font;
extern NSColor*         DFLinkLabel_normalColor;
extern NSColor*         DFLinkLabel_linkColor;
extern BOOL             DFLinkLabel_linkUnderlined;

// Initialization
extern void InitializeDFStyles(void);
