//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>

//-------------------------------------------------------------------------------------------------
// Extension of combo box cell with the right margin that works nicely with bouncing icon view
@interface DFComboBoxCell : NSComboBoxCell

// Right margin
@property (nonatomic) CGFloat rightMargin;

@end
