//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------
// Helpers for anonymizing strings

// Strips string from all mentions of the user full or short name, replacing it with a dummy
extern NSString* AnonymizeString(NSString* inputString);
