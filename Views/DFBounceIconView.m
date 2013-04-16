//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFBounceIconView.h"
#import "DFStyleSheet.h"
#import "NSAnimationWithBlocks.h"

//-------------------------------------------------------------------------------------------------
@implementation DFBounceIconView
{
	NSImage* _icon;
    BOOL _isShowing;
    NSAnimation* _animation;
    BOOL _isAnimatingForward;
    CGFloat _fromOpacity;
    CGFloat _fromSizeFactor;
    BOOL _suppressRefreshDuringAnimation;
}

//-------------------------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) 
	{
        NSAnimationWithBlocks* animation = [[NSAnimationWithBlocks alloc] initWithDuration:DFBounceIcon_animationDuration
                                                                            animationCurve:NSAnimationLinear];
        animation.animationBlockingMode = NSAnimationNonblocking;
        animation.advanceBlock = ^(NSAnimationProgress progress)
        {
            [self animationDidAdvance:progress];
        };
        animation.completionBlock = ^(BOOL isFinished)
        {
            [self animationDidFinish:isFinished];
        };
        _animation = animation;
	}
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[_icon release];
    [_animation release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)isOpaque
{
	return NO;
}

//-------------------------------------------------------------------------------------------------
- (BOOL)isFlipped
{
	return NO;
}

//-------------------------------------------------------------------------------------------------
- (void)setIcon:(NSImage*)icon
{
	if (icon != _icon)
	{
		[icon retain];
		[_icon release];
		_icon = icon;

		self.needsDisplay = YES;
	}
}

//-------------------------------------------------------------------------------------------------
- (void)showWithAnimation:(BOOL)withAnimation
{
    if (withAnimation)
    {
        _fromOpacity = [self calculateCurrentOpacity];
        _fromSizeFactor = [self calculateCurrentSizeFactor];
        _isShowing = YES;
        _isAnimatingForward = YES;
        [self restartAnimation];
    }
    else
    {
        [_animation stopAnimation];
        _isShowing = YES;
        [self animationDidFinish:YES];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)hideWithAnimation:(BOOL)withAnimation
{
    // only hide when not already hidden
    if (_isShowing)
    {
        if (withAnimation)
        {
            _fromOpacity = [self calculateCurrentOpacity];
            _fromSizeFactor = [self calculateCurrentSizeFactor];
            _isAnimatingForward = NO;
            [self restartAnimation];
        }
        else
        {
            [_animation stopAnimation];
            [self animationDidFinish:YES];
        }
    }
}

//-------------------------------------------------------------------------------------------------
- (void)restartAnimation
{
    [_animation stopAnimation];
    _suppressRefreshDuringAnimation = YES;
    _animation.currentProgress = 0.;
    _suppressRefreshDuringAnimation = NO;
    [_animation startAnimation];
}

//-------------------------------------------------------------------------------------------------
- (void)animationDidAdvance:(NSAnimationProgress)progress
{
    if (!_suppressRefreshDuringAnimation)
    {
        self.needsDisplay = YES;
        [self displayIfNeeded];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)animationDidFinish:(BOOL)isFinished
{
    if (isFinished)
    {
        if (!_isAnimatingForward)
        {
            _isShowing = NO;
        }
        self.needsDisplay = YES;
    }
}

//-------------------------------------------------------------------------------------------------
- (CGFloat)calculateCurrentOpacity
{
    CGFloat result = 0.;
    if (_isShowing)
    {
        result = 1.;
        if (_animation.isAnimating)
        {
            CGFloat toOpacity = _isAnimatingForward ? 1. : 0.;
            CGFloat animationValue = _animation.currentValue;
            result = animationValue * (toOpacity - _fromOpacity) + _fromOpacity;
        }
    }
    return result;
}

//-------------------------------------------------------------------------------------------------
- (CGFloat)calculateCurrentSizeFactor
{
    CGFloat result = 1.;
    if (_isShowing)
    {
        if (_animation.isAnimating)
        {
            CGFloat animationValue = _animation.currentValue;
            CGFloat animationPhaseValue = animationValue;
            CGFloat fromSizeFactor = _fromSizeFactor;
            CGFloat toSizeFactor = 1.;
            if (_isAnimatingForward)
            {
                // bounce in
                if (animationValue <= 0.5)
                {
                    toSizeFactor = [self calculateMaxSizeFactor];
                    animationPhaseValue = animationValue * 2.;
                }
                // then bounce out
                else
                {
                    fromSizeFactor = [self calculateMaxSizeFactor];
                    toSizeFactor = 1.;
                    animationPhaseValue = (animationValue - 0.5) * 2.;
                }
            }
            // just bouncing out
            else
            {
                toSizeFactor = 1.;
            }
            result = animationPhaseValue * (toSizeFactor - fromSizeFactor) + fromSizeFactor;
        }
    }
    return result;
}

//-------------------------------------------------------------------------------------------------
- (CGFloat)calculateMaxSizeFactor
{
    CGFloat result = 1.;
    NSSize iconSize = _icon.size;
    if (_icon != nil && iconSize.width > 0. && iconSize.height)
    {
        NSSize boundsSize = self.bounds.size;
        result = fmin(boundsSize.width / iconSize.width, boundsSize.height / iconSize.height);
    }
    return result;
}

//-------------------------------------------------------------------------------------------------
- (void)drawRect:(NSRect)dirtyRect
{
    if (_icon != nil && _isShowing)
    {
        CGFloat currOpacity = [self calculateCurrentOpacity];
        CGFloat currSizeFactor = [self calculateCurrentSizeFactor];
        
        NSRect bounds = self.bounds;
        NSSize iconSize = _icon.size;
        iconSize.width *= currSizeFactor;
        iconSize.height *= currSizeFactor;
        NSRect iconFrame = NSMakeRect(bounds.origin.x + 0.5 * (bounds.size.width - iconSize.width),
                                      bounds.origin.y + 0.5 * (bounds.size.height - iconSize.height),
                                      iconSize.width,
                                      iconSize.height);
        [_icon drawInRect:iconFrame
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:currOpacity
           respectFlipped:YES
                    hints:nil];
        }
}



@end
