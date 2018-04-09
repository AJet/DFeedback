//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "EmailValidation.h"

//-------------------------------------------------------------------------------------------------
BOOL IsEmptyMessage(NSString* string)
{
    BOOL result = YES;
	if ([string length] > 0)
	{
		NSString* regEx = @".*[^ \t\r\n]+.*";
		NSPredicate* test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
		if([test evaluateWithObject:string])
		{
			result = NO;
		}
	}
	return result;
}

//-------------------------------------------------------------------------------------------------
BOOL IsValidEmailAddress(NSString* emailAddress)
{
	if (emailAddress != nil && ![emailAddress isEqualToString:@""])
	{
		NSString* emailRegEx = @"[ ]*[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}[ ]*";
		NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
		if([emailTest evaluateWithObject:emailAddress])
		{
			return YES;
		}
	}
	return NO;
}
