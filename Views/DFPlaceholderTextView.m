//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
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
	if (self)
	{
		// do nothing
	}
	return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[m_placeholderString release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (NSString*)placeholderString
{
	return m_placeholderString;
}

//-------------------------------------------------------------------------------------------------
- (void)setPlaceholderString:(NSString*)value
{
	[value retain];
	[m_placeholderString release];
	m_placeholderString = value;
	[self setNeedsDisplay:YES];
}

//-------------------------------------------------------------------------------------------------
- (void)drawRect:(NSRect)rect
{
	// draw super
	[super drawRect:rect];
	// draw placeholder
	if ([[self string] isEqualToString:@""] && self != [[self window] firstResponder])
	{
		NSRect textRect = NSInsetRect([self bounds], [[self textContainer] lineFragmentPadding], 0.0);
		[m_placeholderString drawInRect:textRect withAttributes:DFPlaceholderTextView_placeholderTextAttributes];
	}
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
