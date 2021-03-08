//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
// Some rights reserved: <https://opensource.org/licenses/mit-license.php>
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
	if (emailAddress != nil && emailAddress.length > 0)
	{
		NSString* emailRegEx = @"^([-a-z0-9._+])+@([a-z0-9])(([a-z0-9._-])*([a-z0-9]))*(\\.([a-z0-9])([a-z0-9_-])*([a-z0-9]))+$";
		NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[cd] %@", emailRegEx];
		if([emailTest evaluateWithObject:emailAddress])
		{
			return YES;
		}
	}
	return NO;
}
