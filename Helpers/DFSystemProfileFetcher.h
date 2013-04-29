//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "DFSystemProfileDataType.h"

@protocol DFSystemProfileFetcherDelegate;

//-------------------------------------------------------------------------------------------------
// Encapsulates asynchronous fetching of system profile
@interface DFSystemProfileFetcher : NSObject

// Delegate
@property (nonatomic, assign) id<DFSystemProfileFetcherDelegate> delegate;

// Begins fetching system profile, completes asynchronously
- (void)fetchDataTypes:(DFSystemProfileDataType)dataTypes
         anonymizeUser:(BOOL)anonymizeUser;

// Cancels a pending request
- (void)cancel;

// Resulting profile
@property (nonatomic, readonly) NSString* profile;

// Is done fetching flag
@property (nonatomic, readonly) BOOL isDoneFetching;

@end
