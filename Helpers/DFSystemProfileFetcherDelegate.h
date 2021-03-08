//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class DFSystemProfileFetcher;

//-------------------------------------------------------------------------------------------------
// System profile fetcher delegate
@protocol DFSystemProfileFetcherDelegate

// Completion, with or without error
- (void)systemProfileFetcherDidFinish:(DFSystemProfileFetcher*)sender;

@end
