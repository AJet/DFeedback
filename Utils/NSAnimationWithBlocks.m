//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "NSAnimationWithBlocks.h"


//-------------------------------------------------------------------------------------------------
// Animation delegate to store completion block
@interface NSAnimationWithBlocksDelegate : NSObject <NSAnimationDelegate>
{
    void (^_completionBlock)(BOOL);
}

@property (nonatomic, copy) void (^completionBlock)(BOOL);

@end

//-------------------------------------------------------------------------------------------------
@implementation NSAnimationWithBlocksDelegate
{
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_completionBlock release];
    [super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)animationDidEnd:(NSAnimation*)animation
{
    if (self.completionBlock != nil)
    {
        self.completionBlock(YES);
    }
}

//-------------------------------------------------------------------------------------------------
- (void)animationDidStop:(NSAnimation*)animation
{
    if (self.completionBlock != nil)
    {
        self.completionBlock(NO);
    }
}

@end

//-------------------------------------------------------------------------------------------------
@interface NSAnimationWithBlocks()

@property (nonatomic, retain) NSAnimationWithBlocksDelegate* retainedDelegate;

@end

//-------------------------------------------------------------------------------------------------
@implementation NSAnimationWithBlocks
{
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_advanceBlock release];
    [_retainedDelegate release];
    [super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)setCurrentProgress:(NSAnimationProgress)progress
{
	[super setCurrentProgress:progress];

    if (self.advanceBlock != nil)
    {
        self.advanceBlock(progress);
    }
}

//-------------------------------------------------------------------------------------------------
- (void(^)(BOOL))completionBlock
{
    void(^result)(BOOL) = nil;
    if (self.delegate != nil && [self.delegate isKindOfClass:[NSAnimationWithBlocksDelegate class]])
    {
        NSAnimationWithBlocksDelegate* delegate = (NSAnimationWithBlocksDelegate*)self.delegate;
        result = delegate.completionBlock;
    }
    return result;
}

//-------------------------------------------------------------------------------------------------
- (void)setCompletionBlock:(void(^)(BOOL))value
{
    if (value == nil)
    {
        self.delegate = nil;
        self.retainedDelegate = nil;
    }
    else
    {
        NSAnimationWithBlocksDelegate* delegate = [[[NSAnimationWithBlocksDelegate alloc] init] autorelease];
        delegate.completionBlock = value;
        self.delegate = delegate;
        self.retainedDelegate = delegate;
    }
}

@end
















