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
		[_rootLayer setFrame:[self bounds]];
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
            // retina support
            [_iconLayer setContentsScale:[_rootLayer contentsScale]];
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
		[opacityAnim setFromValue:@([(CALayer*)[_iconLayer presentationLayer] opacity])];
		[opacityAnim setToValue:@(opacity)];
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
		CGRect bouncedBounds = [_iconLayer bounds];
		bouncedBounds.size.width *= DFBounceIcon_bounceFactor;
		bouncedBounds.size.height *= DFBounceIcon_bounceFactor;
		
		// prepare bounds animation
		CABasicAnimation* boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
        CGRect fromBounds = [_iconLayer presentationLayer] != nil ? [(CALayer*)[_iconLayer presentationLayer] bounds] : [_iconLayer bounds];
		[boundsAnim setFromValue:[NSValue valueWithRect:fromBounds]];
		[boundsAnim setToValue:[NSValue valueWithRect:bouncedBounds]];
		[boundsAnim setDuration:DFBounceIcon_bounceHalfDuration];
		[boundsAnim setAutoreverses:YES];
		
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
        [_rootLayer setContentsScale:[[self window] backingScaleFactor]];
        [_iconLayer setContentsScale:[[self window] backingScaleFactor]];
        // force refresh icon
        [_iconLayer setContents:nil];
        [_iconLayer setContents:_icon];
    }
}

@end
