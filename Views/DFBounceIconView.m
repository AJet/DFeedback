//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
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
    if (self) 
	{
		m_rootLayer = [[CALayer alloc] init];			
		[m_rootLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
		[m_rootLayer setFrame:NSRectToCGRect([self bounds])];
		[m_rootLayer setAnchorPoint:CGPointZero];
		[self setLayer:m_rootLayer];
	}
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[m_rootLayer release];
	[m_iconLayer release];
	[m_icon release];
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
	if (icon != m_icon)
	{
		[icon retain];
		[m_icon release];
		m_icon = icon;
		
		// replace icon layer without animation
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		
		CGFloat opacity = [m_iconLayer opacity];
		[m_iconLayer removeFromSuperlayer];
		[m_iconLayer release];
		m_iconLayer = nil;
		if (icon != nil)
		{
			m_iconLayer = [[CALayer alloc] init];
			[m_iconLayer setFrame:CGRectMake(0.0, 0.0, [icon size].width, [icon size].height)];
			[m_iconLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
			[m_iconLayer setContents:icon];
			[m_iconLayer setOpacity:opacity];
			[m_iconLayer setPosition:CGPointMake([m_rootLayer bounds].size.width * 0.5, [m_rootLayer bounds].size.height * 0.5)];
			[m_rootLayer addSublayer:m_iconLayer];
		}
		
		[CATransaction commit];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)animateOpacity:(CGFloat)opacity
{
	if (m_iconLayer != nil)
	{
		// prepare animation
		CABasicAnimation* opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		[opacityAnim setFromValue:[NSNumber numberWithFloat:[(CALayer*)[m_iconLayer presentationLayer] opacity]]];
		[opacityAnim setToValue:[NSNumber numberWithFloat:opacity]];
		[opacityAnim setDuration:DFBounceIcon_fadeDuration];
		
		// commit value
		[m_iconLayer setOpacity:opacity];
		
		// launch the animation after commit, or the animation will be overriden with the implicit one
		[m_iconLayer addAnimation:opacityAnim forKey:@"opacity"];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)fadeIn
{
	[self animateOpacity:1.0];
	m_isShowing = true;
}

//-------------------------------------------------------------------------------------------------
- (void)fadeOut
{
	[self animateOpacity:0.0];
	m_isShowing = false;
}

//-------------------------------------------------------------------------------------------------
- (bool)isShowing
{
	return m_isShowing;
}

//-------------------------------------------------------------------------------------------------
- (void)show
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	[m_iconLayer setOpacity:1.0];
	m_isShowing = true;
	
	[CATransaction commit];
}

//-------------------------------------------------------------------------------------------------
- (void)hide
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	[m_iconLayer setOpacity:0.0];
	m_isShowing = false;
	
	[CATransaction commit];
}

//-------------------------------------------------------------------------------------------------
- (void)bounce
{
	if (m_iconLayer != nil)
	{
		// calculate bounds
		CGRect bouncedFrame = [m_iconLayer frame];
		bouncedFrame.size.width *= DFBounceIcon_bounceFactor;
		bouncedFrame.size.height *= DFBounceIcon_bounceFactor;
		
		// prepare bounds animation
		CABasicAnimation* boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
		[boundsAnim setFromValue:[NSValue valueWithRect:NSRectFromCGRect([(CALayer*)[m_iconLayer presentationLayer] bounds])]];
		[boundsAnim setToValue:[NSValue valueWithRect:NSRectFromCGRect(bouncedFrame)]];
		[boundsAnim setDuration:DFBounceIcon_bounceHalfDuration];
		[boundsAnim setAutoreverses:YES];
		
		// do not commit value, will return to normal size automatically
		[m_iconLayer addAnimation:boundsAnim forKey:@"bounds"];
	}
}

@end
