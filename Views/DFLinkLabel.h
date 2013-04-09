//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

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
