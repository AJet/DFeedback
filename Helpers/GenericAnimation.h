//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class GenericAnimation;

//-------------------------------------------------------------------------------------------------
// Generic animation delegate
@protocol GenericAnimationDelegate <NSAnimationDelegate>

// Progress
- (void)animation:(GenericAnimation*)animation didProgress:(NSAnimationProgress)progress;

@end

//-------------------------------------------------------------------------------------------------
// Animation that calls delegate on each progress advance
@interface GenericAnimation : NSAnimation

@end
