//
//  TopIOSUtil.m
//  TopIOSSdk
//
//  Created by cenwenchu on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopIOSUtil.h"
#import "GTMBase64.h"

@implementation NSData (TOPEncode)

- (NSString *)MD5EncodedString
{
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], [self length], result);
	
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key
{   
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    void *buffer = malloc(CC_SHA1_DIGEST_LENGTH);
    CCHmac(kCCHmacAlgSHA1, [keyData bytes], [keyData length], [self bytes], [self length], buffer);
	
	NSData *encodedData = [NSData dataWithBytesNoCopy:buffer length:CC_SHA1_DIGEST_LENGTH freeWhenDone:YES];
    return encodedData;
}

- (NSString *)base64EncodedString
{
	return [GTMBase64 stringByEncodingData:self];
}

@end

@implementation NSString(TOPEncode)

- (NSString *)MD5EncodedString
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] MD5EncodedString];
}

- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] HMACSHA1EncodedDataWithKey:key];
}

- (NSString *) base64EncodedString
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

@end

@implementation TopIOSUtil

+ (NSString *)stringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [dict objectForKey:key]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    if (![httpMethod isEqualToString:@"GET"])
    {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [TopIOSUtil stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}


+(void) sign:(NSMutableDictionary *)params appSecret:(NSString *)appSecret
{
    NSArray *myKeys = [params allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSMutableString *src = [[NSMutableString alloc]init];
    [src appendString:appSecret];
    
    for (id key in sortedKeys) {
        [src appendString:key];
        [src appendString:[params objectForKey:key]];
    }
    
    [src appendString:appSecret];
    
    [params setObject:[src MD5EncodedString] forKey:@"sign"];
    
}

+(void)setMultipartPostBody:(NSMutableURLRequest *)req reqParams:(NSMutableDictionary *)reqParams attachs:(NSMutableDictionary *)attachs
{
    NSMutableData *requestData = [[NSMutableData alloc] init];
    NSString *requestBoundary = [NSString stringWithString:@"txwe9802"];
    [requestData appendData:[[NSString stringWithFormat:@"--%@\r\n", requestBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", requestBoundary];
    
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSArray *keys = [reqParams allKeys];
    for (id k in keys){
        [TopIOSUtil setString:[reqParams objectForKey:k] forField:k requestData:requestData requestBoundary:requestBoundary];
    }
    
    keys = [attachs allKeys];
    for (id k in keys){
        [TopIOSUtil setData:[attachs objectForKey:k] forField:k requestData:requestData requestBoundary:requestBoundary];  
    }
    
    [requestData appendData:[[NSString stringWithFormat:@"--%@--\r\n", requestBoundary] dataUsingEncoding:NSUTF8StringEncoding]];    
    
    [req setHTTPBody:requestData];
    
}

+(void)setString:(NSString *)string forField:(NSString *)fieldName requestData:(NSMutableData *)requestData requestBoundary:(NSString *)requestBoundary {
    
    
    NSMutableString *fieldString = [NSMutableString string];
    
    [fieldString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", fieldName];
    [fieldString appendFormat:@"%@\r\n", string];
    [fieldString appendFormat:@"--%@\r\n", requestBoundary];
    
    [requestData appendData:[fieldString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
}


+(void)setData:(NSData *)data forField:(NSString *)fieldName requestData:(NSMutableData *)requestData requestBoundary:(NSString *)requestBoundary{
    
    NSMutableString *fieldString = [NSMutableString string];
    
    [fieldString appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", fieldName];
    [fieldString appendString:@"Content-Type: application/octet-stream\r\n\r\n"];
    
    [requestData appendData:[fieldString dataUsingEncoding:NSUTF8StringEncoding]];
    [requestData appendData:data];
    [requestData appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [requestData appendData:[[NSString stringWithFormat:@"--%@\r\n", requestBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
}

@end
