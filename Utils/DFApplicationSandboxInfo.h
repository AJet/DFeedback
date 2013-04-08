//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------
// Provides sandbox information
@interface DFApplicationSandboxInfo : NSObject

// Checks if the bundle is sandboxed
+ (BOOL)isSandboxed;

// Checks if the bundle has a given entitlement
+ (BOOL)hasAddressBookDataEntitlement;


@end
