//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFBounceIconView.h"
#import "DFStyleSheet.h"

//-------------------------------------------------------------------------------------------------
@implementation DFBounceIconView
//-------------------------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) 
	{
		_rootLayer = [[CALayer alloc] init];			
		[_rootLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
		[_rootLayer setFrame:NSRectToCGRect([self bounds])];
		[_rootLayer setAnchorPoint:CGPointZero];
		[self setLayer:_rootLayer];
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
		
		CGFloat opacity = [_iconLayer opacity];
		[_iconLayer removeFromSuperlayer];
		[_iconLayer release];
		_iconLayer = nil;
		if (icon != nil)
		{
			_iconLayer = [[CALayer alloc] init];
			[_iconLayer setFrame:CGRectMake(0.0, 0.0, [icon size].width, [icon size].height)];
			[_iconLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
			[_iconLayer setContents:icon];
			[_iconLayer setOpacity:opacity];
			[_iconLayer setPosition:CGPointMake([_rootLayer bounds].size.width * 0.5, [_rootLayer bounds].size.height * 0.5)];
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
		CABasicAnimation* opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		[opacityAnim setFromValue:[NSNumber numberWithFloat:[(CALayer*)[_iconLayer presentationLayer] opacity]]];
		[opacityAnim setToValue:[NSNumber numberWithFloat:opacity]];
		[opacityAnim setDuration:DFBounceIcon_fadeDuration];
		
		// commit value
		[_iconLayer setOpacity:opacity];
		
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
- (BOOL)isShowing
{
	return _isShowing;
}

//-------------------------------------------------------------------------------------------------
- (void)show
{
	[CATransaction begin];
    [CATransaction setDisableActions:YES];
	
	[_iconLayer setOpacity:1.0];
	_isShowing = YES;
	
	[CATransaction commit];
}

//-------------------------------------------------------------------------------------------------
- (void)hide
{
	[CATransaction begin];
    [CATransaction setDisableActions:YES];
	
	[_iconLayer setOpacity:0.0];
	_isShowing = NO;
	
	[CATransaction commit];
}

//-------------------------------------------------------------------------------------------------
- (void)bounce
{
	if (_iconLayer != nil)
	{
		// calculate bounds
		CGRect bouncedFrame = [_iconLayer frame];
		bouncedFrame.size.width *= DFBounceIcon_bounceFactor;
		bouncedFrame.size.height *= DFBounceIcon_bounceFactor;
		
		// prepare bounds animation
		CABasicAnimation* boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
		[boundsAnim setFromValue:[NSValue valueWithRect:NSRectFromCGRect([(CALayer*)[_iconLayer presentationLayer] bounds])]];
		[boundsAnim setToValue:[NSValue valueWithRect:NSRectFromCGRect(bouncedFrame)]];
		[boundsAnim setDuration:DFBounceIcon_bounceHalfDuration];
		[boundsAnim setAutoreverses:YES];
		
		// do not commit value, will return to normal size automatically
		[_iconLayer addAnimation:boundsAnim forKey:@"bounds"];
	}
}

@end
