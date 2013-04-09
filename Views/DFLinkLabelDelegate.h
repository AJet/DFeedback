//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class DFLinkLabel;

//-------------------------------------------------------------------------------------------------
// Clickable link delegate
@protocol DFLinkLabelDelegate

// Link clicked
- (void)linkLabel:(DFLinkLabel*)sender didClickLinkNo:(NSUInteger)linkIndex;

@end
