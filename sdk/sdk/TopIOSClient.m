//
//  TopIOSClient.m
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopIOSClient.h"

@implementation TopIOSClient

@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize redirectURI = _redirectURI;
@synthesize accessToken = _accessToken;
@synthesize authEntryUrl = _authEntryUrl;
@synthesize apiEntryUrl = _apiEntryUrl;


-(id)initWithEntryUrl:(NSString *)authurl apiurl:(NSString *)apiurl appKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    if(self = [super init])
    {
        [self setAuthEntryUrl:authurl];
        [self setApiEntryUrl:apiurl];  
        [self setAppKey:appKey];
        [self setAppSecret:appSecret];
    }
    
    return self;
}

-(void)dealloc
{
    [self setAppKey:nil];
    [self setAppSecret:nil];
    [self setRedirectURI:nil];
    [self setAccessToken:nil];
    [self setAuthEntryUrl:nil];
    [self setApiEntryUrl:nil];
}


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
	NSString *query = [TopIOSClient stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}



-(void)auth:(UIWebView *) authView;
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_appKey,@"client_id",
                            @"token",@"response_type",
                            @"wap",@"view",nil];
    
    
    if (_redirectURI)
    {
        [params setObject:_redirectURI forKey:@"redirect_uri"];
    }
    
    NSString *urlString = [TopIOSClient serializeURL:_authEntryUrl
                                              params:params httpMethod:@"GET"];

    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlString]];
    
    [authView loadRequest:req];
    
}

-(void)api:(NSString *)type method:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb;
{
    NSMutableDictionary *reqParams = [[NSMutableDictionary alloc] init];
    
    [reqParams addEntriesFromDictionary:params];
    [reqParams setObject:@"json" forKey:@"format"];
    [reqParams setObject:_appKey forKey:@"app_key"];
    [reqParams setObject:@"2.0" forKey:@"v"];
    [reqParams setObject:@"md5" forKey:@"sign_method"];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [reqParams setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"timestamp"];
    
    if (_accessToken)
        [reqParams setObject:_accessToken forKey:@"session"];
    
    [self sign:reqParams];

    
    NSMutableString *body = [[NSMutableString alloc]init];
    NSURL *url = [NSURL URLWithString:_apiEntryUrl];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    NSEnumerator *enumerator = [reqParams keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject])) {
        [body appendString:key];        
        [body appendString:@"=" ];
        [body appendString:[reqParams objectForKey:key]];
        [body appendString:@"&" ];
    }
    
    NSLog(@"%@", body);
    NSData *d = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [req setHTTPMethod:method];
    [req setHTTPBody:d];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *resp,NSData *data,NSError *error){
        
        if (error == nil)
        {
            [target performSelectorOnMainThread:cb withObject:data waitUntilDone:TRUE];
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error); }
        
        [self sendNotificationMessage:error target:target];
        
    }];
    
}


-(void) sendNotificationMessage:(NSError *)error target:(id)target{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:error forKey:@"error"];
    
    NSNotification *NotificationObj = [NSNotification notificationWithName:MessageArriveNotification object:target userInfo:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotification:NotificationObj];
    
}

-(void) sign:(NSMutableDictionary *)params
{
    NSArray *myKeys = [params allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
   
    NSMutableString *src = [[NSMutableString alloc]init];
    [src appendString:_appSecret];
    
    for (id key in sortedKeys) {
        [src appendString:key];
        [src appendString:[params objectForKey:key]];
    }
    
    [src appendString:_appSecret];
    
    [params setObject:[src MD5EncodedString] forKey:@"sign"];
    
}


@end
