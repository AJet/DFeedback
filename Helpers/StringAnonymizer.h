//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------
// Helpers for anonymizing strings

// Strips string from all mentions of the user full or short name, replacing it with a dummy
extern NSString* AnonymizeString(NSString* inputString);