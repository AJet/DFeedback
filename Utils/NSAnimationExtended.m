//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "NSAnimationExtended.h"

//-------------------------------------------------------------------------------------------------
@implementation NSAnimationExtended
{
}

//-------------------------------------------------------------------------------------------------
- (void)setCurrentProgress:(NSAnimationProgress)progress
{
	[super setCurrentProgress:progress];

    if ([self.delegate conformsToProtocol:@protocol(NSAnimationExtendedDelegate)])
    {
        [(id<NSAnimationExtendedDelegate>)self.delegate animation:self
                                                      didProgress:progress];
    }
}

@end
















