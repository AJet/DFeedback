//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFPlaceholderTextView.h"
#import "DFStyleSheet.h"

//-------------------------------------------------------------------------------------------------
@implementation DFPlaceholderTextView
//-------------------------------------------------------------------------------------------------
{
	NSString* m_placeholderText;
	bool m_shouldInvalidateOnChange;
}

//-------------------------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		// do nothing
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[m_placeholderText release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (NSString*)placeholderText
{
	return m_placeholderText;
}

//-------------------------------------------------------------------------------------------------
- (void)setPlaceholderText:(NSString*)value
{
	[value retain];
	[m_placeholderText release];
	m_placeholderText = value;
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
	if (m_shouldInvalidateOnChange)
	{
		[self setNeedsDisplay:YES];
	}
	m_shouldInvalidateOnChange = ([self string] == nil || [[self string] isEqualToString:@""]);
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
