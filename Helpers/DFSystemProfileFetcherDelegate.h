//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class DFSystemProfileFetcher;

//-------------------------------------------------------------------------------------------------
// System profile fetcher delegate
@protocol DFSystemProfileFetcherDelegate

// Completion, with or without error
- (void)systemProfileFetcherDidFinish:(DFSystemProfileFetcher*)sender;

@end
