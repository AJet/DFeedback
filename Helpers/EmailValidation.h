//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------
// Helpers for e-mail validation

// Empty message test
extern BOOL IsEmptyMessage(NSString* string);

// Address validation
extern BOOL IsValidEmailAddress(NSString* emailAddress);
