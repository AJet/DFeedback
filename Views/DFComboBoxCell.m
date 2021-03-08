//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFComboBoxCell.h"

//-------------------------------------------------------------------------------------------------
@implementation DFComboBoxCell

//-------------------------------------------------------------------------------------------------
- (void)setRightMargin:(CGFloat)value
{
    if (value != _rightMargin)
    {
        _rightMargin = value;
        NSControl* control = (NSControl*)self.controlView;
        control.needsDisplay = YES;
        // NOTE: this will not update field editor if it's already editing, so you can't change the margin dynamically
        // to be able to do that, you need to check if the field is the first responder, get the current field editor
        // and call selectWithFrame:..., however it's not supposed to be used like that and is buggy
        // particularly, the last text change may be lost on calling selectWithFrame:...
    }
}

//-------------------------------------------------------------------------------------------------
- (NSRect)drawingRectForBounds:(NSRect)bounds
{
    NSRect superBounds = [super drawingRectForBounds:bounds];
    superBounds.size.width -= self.rightMargin;
    return superBounds;
}

@end
