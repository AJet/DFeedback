//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "NSURLRequest+Extension.h"

//-------------------------------------------------------------------------------------------------
@implementation NSURLRequest(Extension)
//-------------------------------------------------------------------------------------------------
+ (void)appendString:(NSString*)string toData:(NSMutableData*)data
{
    [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

//-------------------------------------------------------------------------------------------------
+ (void)appendFormat:(NSString*)format arg:(NSString*)arg toData:(NSMutableData*)data
{
	NSString *string = [NSString stringWithFormat:format, arg];
    [self appendString:string toData:data];
}

//-------------------------------------------------------------------------------------------------
+ (NSURLRequest*)requestWithURL:(NSURL*)url postForm:(NSDictionary*)values 
{
    // create the mime multipart boundary
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString* uuid = [(NSString *)uuidStringRef autorelease];
    NSString* boundary = [NSString stringWithFormat:@"x-mime-boundary://%@", uuid];
    
    // create the form
    NSMutableData* formData = [NSMutableData data];
    for (NSString* key in [values allKeys]) 
	{
        [NSURLRequest appendFormat:@"\r\n--%@\r\n" arg:boundary toData:formData];
        [NSURLRequest appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n" arg:key toData:formData];
        id value = [values objectForKey:key];
        if ([value isKindOfClass:[NSData class]]) 
		{
            [NSURLRequest appendString:@"\r\n" toData:formData];
            [formData appendData:value];
        } 
		else if ([value isKindOfClass:[NSString class]]) 
		{
            [NSURLRequest appendFormat:@"Content-Type: text/plain; charset=utf-8\r\n\r\n" arg:nil toData:formData];
            [NSURLRequest appendString:value toData:formData];
        } 
		else 
		{
            NSAssert1(NO, @"unknown value class: %@", [value className]);
        }
    }
    [NSURLRequest appendFormat:@"\r\n--%@--\r\n" arg:boundary toData:formData];
    
    // create request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [formData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:formData];
    
    return request;
}

@end
