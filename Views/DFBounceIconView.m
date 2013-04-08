//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFBounceIconView.h"
#import "DFStyleSheet.h"

//-------------------------------------------------------------------------------------------------
@implementation DFBounceIconView
{
	CALayer* _rootLayer;
	CALayer* _iconLayer;
	BOOL _isShowing;
	NSImage* _icon;
}

//-------------------------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) 
	{
		_rootLayer = [[CALayer alloc] init];			
		_rootLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
		_rootLayer.frame = self.bounds;
		_rootLayer.anchorPoint = CGPointZero;
		self.layer = _rootLayer;
	}
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[_rootLayer release];
	[_iconLayer release];
	[_icon release];
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
		
		// replace icon layer without animation
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		
		CGFloat opacity = _iconLayer.opacity;
		[_iconLayer removeFromSuperlayer];
		[_iconLayer release];
		_iconLayer = nil;
		if (icon != nil)
		{
			_iconLayer = [[CALayer alloc] init];
			_iconLayer.frame = CGRectMake(0.0, 0.0, icon.size.width, icon.size.height);
			_iconLayer.anchorPoint = CGPointMake(0.5, 0.5);
            // retina support
            _iconLayer.contentsScale = _rootLayer.contentsScale;
			_iconLayer.contents = icon;
			_iconLayer.opacity = opacity;
			_iconLayer.position = CGPointMake(_rootLayer.bounds.size.width * 0.5, _rootLayer.bounds.size.height * 0.5);
			[_rootLayer addSublayer:_iconLayer];
		}
		
		[CATransaction commit];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)animateOpacity:(CGFloat)opacity
{
	if (_iconLayer != nil)
	{
		// prepare animation
        CALayer* opacityLayer = _iconLayer.presentationLayer != nil ? _iconLayer.presentationLayer : _iconLayer;
		CABasicAnimation* opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		opacityAnim.fromValue = @(opacityLayer.opacity);
		opacityAnim.toValue = @(opacity);
		opacityAnim.duration = DFBounceIcon_fadeDuration;
		
		// commit to-value
		_iconLayer.opacity = opacity;
		
		// launch the animation after commit, or the animation will be overriden with the implicit one
		[_iconLayer addAnimation:opacityAnim forKey:@"opacity"];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)fadeIn
{
	[self animateOpacity:1.0];
	_isShowing = YES;
}

//-------------------------------------------------------------------------------------------------
- (void)fadeOut
{
	[self animateOpacity:0.0];
	_isShowing = NO;
}

//-------------------------------------------------------------------------------------------------
- (void)show
{
	[CATransaction begin];
    [CATransaction setDisableActions:YES];
	
	_iconLayer.opacity = 1.0;
	_isShowing = YES;
	
	[CATransaction commit];
}

//-------------------------------------------------------------------------------------------------
- (void)hide
{
	[CATransaction begin];
    [CATransaction setDisableActions:YES];
	
	_iconLayer.opacity = 0.0;
	_isShowing = NO;
	
	[CATransaction commit];
}

//-------------------------------------------------------------------------------------------------
- (void)bounce
{
	if (_iconLayer != nil)
	{
		// calculate bounds
		CGRect bouncedBounds = _iconLayer.bounds;
		bouncedBounds.size.width *= DFBounceIcon_bounceFactor;
		bouncedBounds.size.height *= DFBounceIcon_bounceFactor;
		
		// prepare bounds animation
        CALayer* boundsLayer = _iconLayer.presentationLayer != nil ? _iconLayer.presentationLayer : _iconLayer;
		CABasicAnimation* boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
        CGRect fromBounds = boundsLayer.bounds;
		boundsAnim.fromValue = [NSValue valueWithRect:fromBounds];
		boundsAnim.toValue = [NSValue valueWithRect:bouncedBounds];
		boundsAnim.duration = DFBounceIcon_bounceHalfDuration;
		boundsAnim.autoreverses = YES;
		
		// do not commit value, will return to normal size automatically
		[_iconLayer addAnimation:boundsAnim forKey:@"bounds"];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)viewDidChangeBackingProperties
{
    if (self.window != nil)
    {
        // retina support
        _rootLayer.contentsScale = self.window.backingScaleFactor;
        _iconLayer.contentsScale = self.window.backingScaleFactor;
        // force refresh icon
        _iconLayer.contents = nil;
        _iconLayer.contents = _icon;
    }
}

@end
