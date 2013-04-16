//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Animation that calls block of code on each progress advance
@interface NSAnimationWithBlocks : NSAnimation

// Sets advance block
@property (nonatomic, copy) void (^advanceBlock)(NSAnimationProgress);

// Sets completion block (using delegate)
@property (nonatomic, copy) void (^completionBlock)(BOOL finished);


@end
