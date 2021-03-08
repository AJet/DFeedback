//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// A text view subclass that displays a placeholder text when it's empty and not key
@interface DFPlaceholderTextView : NSTextView

// Placeholder text
// NOTE: this property is intentionally named differently than placeholderString, to avoid clashing
// with undocumented NSTextView's method that seems to do the same thing and causes the text to double
@property (nonatomic, retain) NSString* placeholderText;


@end
