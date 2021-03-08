//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------
// Provides sandbox information
@interface ApplicationSandboxInfo : NSObject

// Checks if the bundle is sandboxed
+ (BOOL)isSandboxed;

// Checks if the bundle has a given entitlement
+ (BOOL)hasAddressBookDataEntitlement;


@end
