//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFPlaceholderTextView.h"
#import "DFStyleSheet.h"

//-------------------------------------------------------------------------------------------------
@implementation DFPlaceholderTextView
//-------------------------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		// do nothing
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[_placeholderText release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (NSString*)placeholderText
{
	return _placeholderText;
}

//-------------------------------------------------------------------------------------------------
- (void)setPlaceholderText:(NSString*)value
{
	[value retain];
	[_placeholderText release];
	_placeholderText = value;
	[self setNeedsDisplay:YES];
}

//-------------------------------------------------------------------------------------------------
- (void)drawRect:(NSRect)rect
{
	// draw super
	[super drawRect:rect];

	[NSGraphicsContext saveGraphicsState];

	// draw placeholder
	if (([self string] == nil || [[self string] isEqualToString:@""]) && self != [[self window] firstResponder])
	{
		NSRect textRect = NSInsetRect([self bounds], [[self textContainer] lineFragmentPadding], 0.0);
		[[self placeholderText] drawInRect:textRect withAttributes:DFPlaceholderTextView_placeholderTextAttributes];
	}
	
	[NSGraphicsContext restoreGraphicsState];
}

//-------------------------------------------------------------------------------------------------
- (void)didChangeText
{
	[super didChangeText];
	// clear explicitly, or otherwise the placeholder text will sometimes leave some dirty pixels
	if (_shouldInvalidateOnChange)
	{
		[self setNeedsDisplay:YES];
	}
	_shouldInvalidateOnChange = ([self string] == nil || [[self string] isEqualToString:@""]);
}

//-------------------------------------------------------------------------------------------------
- (BOOL)becomeFirstResponder
{
	[self setNeedsDisplay:YES];
	return [super becomeFirstResponder];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)resignFirstResponder
{
	[self setNeedsDisplay:YES];
	return [super resignFirstResponder];
}

@end
