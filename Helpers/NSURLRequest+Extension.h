//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------
// Extension to NSURLRequest with utilities
@interface NSURLRequest (Extension)

// Create request with HTTP POST form
+ (NSURLRequest*)requestWithUrl:(NSURL*)url
                       postForm:(NSDictionary*)values;

@end
