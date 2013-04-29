//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "GenericAnimation.h"

//-------------------------------------------------------------------------------------------------
@implementation GenericAnimation

//-------------------------------------------------------------------------------------------------
- (void)setCurrentProgress:(NSAnimationProgress)progress
{
	[super setCurrentProgress:progress];

    if ([self.delegate conformsToProtocol:@protocol(GenericAnimationDelegate)])
    {
        [(id<GenericAnimationDelegate>)self.delegate animation:self
                                                   didProgress:progress];
    }
}

@end
















