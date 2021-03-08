//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>

@protocol DFLinkLabelDelegate;

//-------------------------------------------------------------------------------------------------
// A text label that can contain clickable hyperlink
@interface DFLinkLabel : NSView

// Initializer from existing text field, to take its text, font and frame
- (id)initWithTextField:(NSTextField*)textField;

// String value, hyperlinks enclosed in [square brackets]
@property (nonatomic, retain) NSString* stringValue;

// Delegate
@property (nonatomic, assign) id<DFLinkLabelDelegate> delegate;

@end
