//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class NSAnimationExtended;

//-------------------------------------------------------------------------------------------------
// Extended animation delegate
@protocol NSAnimationExtendedDelegate <NSAnimationDelegate>

// Progress
- (void)animation:(NSAnimationExtended*)animation didProgress:(NSAnimationProgress)progress;

@end

//-------------------------------------------------------------------------------------------------
// Animation that calls delegate on each progress advance
@interface NSAnimationExtended : NSAnimation

@end
