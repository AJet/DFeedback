//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "StringAnonymizer.h"

//-------------------------------------------------------------------------------------------------
static NSString* const kObscuredUserName = @"<user name>";
static NSString* const kObscuredUserFullName = @"<user full name>";

//-------------------------------------------------------------------------------------------------
NSString* AnonymizeString(NSString* inputString)
{
    NSString* result = inputString;
    if (inputString != nil)
    {
        // remove full name
        NSString* userFullName = NSFullUserName();
        result = [result stringByReplacingOccurrencesOfString:userFullName
                                                   withString:kObscuredUserFullName
                                                      options:NSCaseInsensitiveSearch
                                                        range:NSMakeRange(0, result.length)];
        // remove short name
        NSString* userName = NSUserName();
        result = [result stringByReplacingOccurrencesOfString:userName
                                                   withString:kObscuredUserName
                                                      options:NSCaseInsensitiveSearch
                                                        range:NSMakeRange(0, result.length)];
    }
    return result;
}
