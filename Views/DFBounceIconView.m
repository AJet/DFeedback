//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFBounceIconView.h"
#import "DFStyleSheet.h"
#import "GenericAnimation.h"

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
        _animation = [[GenericAnimation alloc] initWithDuration:DFBounceIcon_animationDuration
                                                    animationCurve:NSAnimationLinear];
        _animation.animationBlockingMode = NSAnimationNonblocking;
        _animation.delegate = self;
	}
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[_icon release];
    _animation.delegate = nil;
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
    _isAnimatingForward = YES;
    _isShowing = YES;

    if (withAnimation)
    {
        _fromOpacity = [self calculateCurrentOpacity];
        _fromSizeFactor = [self calculateCurrentSizeFactor];
        [self restartAnimation];
    }
    else
    {
        [_animation stopAnimation];
        [self animationDidComplete:YES];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)hideWithAnimation:(BOOL)withAnimation
{
    // only hide when not already hidden
    if (_isShowing)
    {
        _isAnimatingForward = NO;
        if (withAnimation)
        {
            _fromOpacity = [self calculateCurrentOpacity];
            _fromSizeFactor = [self calculateCurrentSizeFactor];
            [self restartAnimation];
        }
        else
        {
            [_animation stopAnimation];
            [self animationDidComplete:YES];
        }
    }
}

//-------------------------------------------------------------------------------------------------
- (void)restartAnimation
{
    [_animation stopAnimation];
    _animation.duration = DFBounceIcon_animationDuration;
    _suppressRefreshDuringAnimation = YES;
    _animation.currentProgress = 0.;
    _suppressRefreshDuringAnimation = NO;
    [_animation startAnimation];
}

//-------------------------------------------------------------------------------------------------
- (void)animation:(GenericAnimation*)animation didProgress:(NSAnimationProgress)progress
{
    if (animation == _animation)
    {
        if (!_suppressRefreshDuringAnimation)
        {
            self.needsDisplay = YES;
            [self displayIfNeeded];
        }
    }
}

//-------------------------------------------------------------------------------------------------
- (void)animationDidStop:(NSAnimation*)animation
{
    if (animation == _animation)
    {
        [self animationDidComplete:NO];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)animationDidEnd:(NSAnimation*)animation
{
    if (animation == _animation)
    {
        [self animationDidComplete:YES];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)animationDidComplete:(BOOL)isFinished
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
        NSRect bounds = self.bounds;
        NSSize iconSize = _icon.size;

        // calculate center
        NSPoint center = NSMakePoint(bounds.origin.x + 0.5 * bounds.size.width,
                                     bounds.origin.y + 0.5 * bounds.size.height);
        // make sure we have integer pixels when not animating
        center.x = round(center.x);
        center.y = round(center.y);
        
        CGFloat currOpacity = [self calculateCurrentOpacity];
        CGFloat currSizeFactor = [self calculateCurrentSizeFactor];
        
        iconSize.width *= currSizeFactor;
        iconSize.height *= currSizeFactor;
        NSRect iconFrame = NSMakeRect(center.x - 0.5 * iconSize.width,
                                      center.y - 0.5 * iconSize.height,
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
