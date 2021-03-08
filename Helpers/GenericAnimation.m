//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
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
        // it was found that sometimes the auto-release of objects during animation is postponed
        // which may cause build-up of significant amount of used memory
        // so auto-release explicitly
        @autoreleasepool
        {
            [(id<GenericAnimationDelegate>)self.delegate animation:self
                                                       didProgress:progress];
        }
    }
}

@end
















