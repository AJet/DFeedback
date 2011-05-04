//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Customizable style constants that define some appearance and behavior properties of all elements
//-------------------------------------------------------------------------------------------------
// Bounce icon
extern CGFloat			DFBounceIcon_bounceFactor;
extern NSTimeInterval	DFBounceIcon_bounceHalfDuration;
extern NSTimeInterval	DFBounceIcon_fadeDuration;

//-------------------------------------------------------------------------------------------------
// Placeholder text view
extern NSDictionary*	DFPlaceholderTextView_placeholderTextAttributes;

//-------------------------------------------------------------------------------------------------
// Window
extern CGFloat			DFWindow_bottomBarHeight;
extern NSImage*			DFWindow_emailWarningImage;

//-------------------------------------------------------------------------------------------------
// Initialization
void initializeDFStyles();
