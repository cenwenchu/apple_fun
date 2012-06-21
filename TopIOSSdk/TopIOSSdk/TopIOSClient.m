//
//  TopIOSClient.m
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopIOSClient.h"
#import "TopIOSUtil.h"


@interface TopIOSClient()
    @property(readonly) NSString *trackId;
    @property(copy,atomic) NSString *authEntryUrl;
    @property(copy,atomic) NSString *apiEntryUrl;
    @property(copy,atomic) NSString *authRefreshEntryUrl;
    @property(copy,atomic) NSString *sysName;
    @property(copy,atomic) NSString *sysVersion;
    
    @property NSOperationQueue *queue;
    @property(strong,nonatomic)UIWebView *authView;
    @property NSTimer *autoWorker;
@end


@implementation TopIOSClient


@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize callbackUrl = _callbackUrl;
@synthesize topAuth = _topAuth;
@synthesize authEntryUrl = _authEntryUrl;
@synthesize apiEntryUrl = _apiEntryUrl;
@synthesize authRefreshEntryUrl = _authRefreshEntryUrl;
@synthesize trackId = _trackId;
@synthesize needAutoRefreshToken = _needAutoRefreshToken;
@synthesize queue;
@synthesize authView;
@synthesize sysName;
@synthesize sysVersion;
@synthesize autoWorker;

-(id)initIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl needAutoRefreshToken:(BOOL)needAutoRefreshToken
{
    if(self = [super init])
    {
        [self setAuthEntryUrl:@"https://oauth.taobao.com/authorize"];
        [self setApiEntryUrl:@"http://gw.api.taobao.com/router/rest"];  
        [self setAuthRefreshEntryUrl:@"https://oauth.taobao.com/token"];
        [self setAppKey:appKey];
        [self setAppSecret:appSecret];
        [self setCallbackUrl:callbackUrl];
        [self setNeedAutoRefreshToken:needAutoRefreshToken];
        
        [self setSysName:[[UIDevice currentDevice] systemName]];
        [self setSysVersion:[[UIDevice currentDevice] systemVersion]];
        
        if(needAutoRefreshToken)
            autoWorker = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refreshToken) userInfo:nil repeats:true];
        
        queue = [[NSOperationQueue alloc] init];
        authView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        [authView setDelegate:self];
        [authView setScalesPageToFit:YES];
        [authView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        
    }
    
    return self;
}

-(void)dealloc
{
    [self setAppKey:nil];
    [self setAppSecret:nil];
    [self setCallbackUrl:nil];
    [self setAuthEntryUrl:nil];
    [self setApiEntryUrl:nil];
    [self setAuthRefreshEntryUrl:nil];
    [self setQueue:nil];
    [self setAuthView:nil];
    [self setSysVersion:nil];
    [self setSysName:nil];
    _topAuth = nil;
    
    if (_needAutoRefreshToken)
    {
        [autoWorker invalidate];
        [self setAutoWorker:nil];
    }

}

-(void)refreshToken
{
    if(_topAuth && [_topAuth refresh_interval] > 0)
    {
        NSDate *now = [NSDate date];
        int i = ([[_topAuth refresh_interval] intValue] * 7/10);
        
        NSDate *checkDate = [[_topAuth beg_time] dateByAddingTimeInterval:i];
        
        if([checkDate earlierDate:now])
        {
            
            NSMutableDictionary *reqParams = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
            
            
            [reqParams setObject:_appKey forKey:@"client_id"];
            [reqParams setObject:_appSecret forKey:@"client_secret"];
            [reqParams setObject:@"refresh_token" forKey:@"grant_type"];
            [reqParams setObject:[_topAuth refresh_token] forKey:@"refresh_token"];
            
            NSLog(@" token : %@",[_topAuth refresh_token]);
            
            if (sysVersion)
                [headers setObject:sysVersion forKey:@"client_sysVersion"];
            
            if (sysName)
                [headers setObject:sysName forKey:@"client_sysName"];
            
            if (_trackId)
                [headers setObject:_trackId forKey:@"track_id"];
            
            NSMutableString *body = [[NSMutableString alloc]init];
            NSURL *url = [NSURL URLWithString:_authRefreshEntryUrl];
            
            NSEnumerator *enumerator = [reqParams keyEnumerator];
            id key;
            
            while ((key = [enumerator nextObject])) {
                [body appendString:key];        
                [body appendString:@"=" ];
                [body appendString:[[reqParams objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [body appendString:@"&" ];
            }
            
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url 
                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
                
            NSData *d = [body dataUsingEncoding:NSUTF8StringEncoding];
            [req setHTTPBody:d];
            
            
            [req setHTTPMethod:@"POST"];
            [req setAllHTTPHeaderFields:headers];
            
            NSOperationQueue *q = [[NSOperationQueue alloc] init];
            
            [NSURLConnection sendAsynchronousRequest:req queue:q completionHandler:^(NSURLResponse *resp,NSData *data,NSError *error){
                
                if (error == nil)
                {
                    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                }
                else if (error != nil){
                    NSLog(@"Error happened = %@", error); 
                }
            }];

            
        }
    }
}

-(void)auth:(UIViewController *) currentViewController
{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_appKey,@"client_id",
                            @"token",@"response_type",
                            @"wap",@"view",nil];
    
    
    if (_callbackUrl)
    {
        [params setObject:_callbackUrl forKey:@"redirect_uri"];
    }
    
    NSString *urlString = [TopIOSUtil serializeURL:_authEntryUrl
                                              params:params httpMethod:@"GET"];

    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlString]];
    
    [authView loadRequest:req];
    [self showAuthView];
}

-(void)oauthCallback:(NSString *)authString
{
    if(_topAuth)
        _topAuth =nil;
    
    _topAuth = [[TopAuth alloc] initTopAuthFromString:authString];  
    
    NSLog(@" token : %@",[_topAuth refresh_token]);
    
    NSMutableString *s = [[NSMutableString alloc] initWithString:_appKey];
    [s appendString:@"-"];
    [s appendString:_appSecret];
    [s appendString:@"-"];
    [s appendString:[_topAuth user_id]];
    
    _trackId = [s MD5EncodedString];
    
}

-(void)api:(BOOL)isHttps method:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb
{
    NSMutableDictionary *reqParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    [reqParams addEntriesFromDictionary:params];
    [reqParams setObject:@"json" forKey:@"format"];
    
    if (_appKey)
        [reqParams setObject:_appKey forKey:@"app_key"];
    
    [reqParams setObject:@"2.0" forKey:@"v"];
    [reqParams setObject:@"md5" forKey:@"sign_method"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [reqParams setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"timestamp"];
    
    if (_topAuth)
        [reqParams setObject:[_topAuth access_token]  forKey:@"session"];
    
    if (sysVersion)
        [headers setObject:sysVersion forKey:@"client_sysVersion"];
        
    if (sysName)
        [headers setObject:sysName forKey:@"client_sysName"];
    
    if (_trackId)
        [headers setObject:_trackId forKey:@"track_id"];

    
    [TopIOSUtil sign:reqParams appSecret:_appSecret];
    
    
    NSMutableString *body = [[NSMutableString alloc]init];
    NSURL *url = [NSURL URLWithString:_apiEntryUrl];
    
    NSEnumerator *enumerator = [reqParams keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject])) {
        [body appendString:key];        
        [body appendString:@"=" ];
        [body appendString:[[reqParams objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [body appendString:@"&" ];
    }
    
    NSMutableURLRequest *req = nil;
    
    if (![method caseInsensitiveCompare:@"Get"])
    {
        NSString *_url = [_apiEntryUrl stringByAppendingString:@"?"];
        _url = [_url stringByAppendingString:body];
        
        NSLog(@"%@",_url);
        
        req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: _url] 
                                       cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
        
    }
    else {
        req = [NSMutableURLRequest requestWithURL:url 
                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
        
        NSData *d = [body dataUsingEncoding:NSUTF8StringEncoding];
        [req setHTTPBody:d];
    }
    
    [req setHTTPMethod:[method uppercaseString]];
    [req setAllHTTPHeaderFields:headers];
    
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *resp,NSData *data,NSError *error){
        
        if (error == nil)
        {
            [target performSelectorOnMainThread:cb withObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] waitUntilDone:TRUE];
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error); 
            [target performSelectorOnMainThread:cb withObject:error waitUntilDone:TRUE];
        }
    }];
    
}


//web view delegate method , get hash from url

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *url = [[[webView request] URL] absoluteString];
    
    NSArray *listItems = [url componentsSeparatedByString:@"#"];
    
    NSEnumerator *enumerator = [listItems objectEnumerator];
    id anObject;
    
    while (anObject = [enumerator nextObject]) {
        
        NSRange range = [(NSString *)anObject rangeOfString:@"access_token="];
        
        if (range.location == NSNotFound)
            continue;
        else {
            NSLog(@"%@",(NSString *)anObject);
            
            [self oauthCallback:(NSString *)anObject];
            [self hideAuthView];
            break;
        }
    }
    
}


//authView show or hide
- (void)showAuthView
{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window)
    {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
  	[window addSubview:authView];

}

- (void)hideAuthView
{ 
    [authView removeFromSuperview];
}

@end
