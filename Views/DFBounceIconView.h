//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "NSAnimationExtended.h"

//-------------------------------------------------------------------------------------------------
// A custom view that displays a bouncing icon to visually attract user's attention to an input error
// NOTE: The view needs to be slightly larger than its icon, to allow room for bouncing
@interface DFBounceIconView : NSView <NSAnimationExtendedDelegate>

// The icon
@property (nonatomic, retain) NSImage* icon;

// Shows/hides with/without fade and bounce animations
- (void)showWithAnimation:(BOOL)withAnimation;

- (void)hideWithAnimation:(BOOL)withAnimation;


// Currently showing flag
@property (nonatomic, readonly) BOOL isShowing;

@end
