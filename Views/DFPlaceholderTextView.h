//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// A text view subclass that displays a placeholder text when it's empty and not key
//-------------------------------------------------------------------------------------------------
@interface DFPlaceholderTextView : NSTextView
{
	NSString* m_placeholderString;
}

//-------------------------------------------------------------------------------------------------
// Public instance methods
//-------------------------------------------------------------------------------------------------
// Placeholder string
- (NSString*)placeholderString;
- (void)setPlaceholderString:(NSString*)value;

@end
