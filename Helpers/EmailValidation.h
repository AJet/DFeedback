//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------
// Helpers for e-mail validation

// Empty message test
extern BOOL IsEmptyMessage(NSString* string);

// Address validation
extern BOOL IsValidEmailAddress(NSString* emailAddress);
