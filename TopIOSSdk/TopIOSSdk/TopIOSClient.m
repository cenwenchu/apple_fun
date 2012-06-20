//
//  TopIOSClient.m
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopIOSClient.h"
#import "TopIOSUtil.h"
#import "TopAuth.h"

@interface TopIOSClient()
    @property(readonly) NSString *trackId;

    @property(copy,atomic) NSString *appKey;
    @property(copy,atomic) NSString *appSecret;
    @property(copy,atomic) NSString *callbackUrl;
    @property(copy,atomic) TopAuth *topAuth;

    @property(copy,atomic) NSString *authEntryUrl;
    @property(copy,atomic) NSString *apiEntryUrl;

    @property NSOperationQueue *queue;
    @property(strong,nonatomic)UIWebView *authView;
@end


@implementation TopIOSClient


@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize callbackUrl = _callbackUrl;
@synthesize topAuth = _topAuth;
@synthesize authEntryUrl = _authEntryUrl;
@synthesize apiEntryUrl = _apiEntryUrl;
@synthesize trackId = _trackId;
@synthesize queue;
@synthesize authView;

-(id)initIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl
{
    if(self = [super init])
    {
        [self setAuthEntryUrl:@"https://oauth.taobao.com/authorize"];
        [self setApiEntryUrl:@"http://gw.api.taobao.com/router/rest"];  
        [self setAppKey:appKey];
        [self setAppSecret:appSecret];
        [self setCallbackUrl:callbackUrl];
        
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
    [self setTopAuth:nil];
    [self setAuthEntryUrl:nil];
    [self setApiEntryUrl:nil];
    [self setQueue:nil];
    [self setAuthView:nil];
}

-(void)auth:(UIViewController *) currentViewController;
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

-(void)oauthCallback:(NSString *)authString;
{
    if(_topAuth)
        [self setTopAuth:nil];
    
    _topAuth = [[TopAuth alloc] initTopAuthFromString:authString];    
    
    NSMutableString *s = [[NSMutableString alloc] initWithString:_appKey];
    [s appendString:@"-"];
    [s appendString:_appSecret];
    [s appendString:@"-"];
    [s appendString:[_topAuth user_id]];
    
    _trackId = [s MD5EncodedString];
    
}

-(void)api:(BOOL)isHttps method:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb;
{
    NSMutableDictionary *reqParams = [[NSMutableDictionary alloc] init];
    
    [reqParams addEntriesFromDictionary:params];
    [reqParams setObject:@"json" forKey:@"format"];
    
    if (_appKey)
        [reqParams setObject:_appKey forKey:@"app_key"];
    
    [reqParams setObject:@"2.0" forKey:@"v"];
    [reqParams setObject:@"md5" forKey:@"sign_method"];
    
    if (_trackId)
        [reqParams setObject:_trackId forKey:@"track_id"];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [reqParams setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"timestamp"];
    
    if (_topAuth)
        [reqParams setObject:[_topAuth access_token]  forKey:@"session"];
    
    [TopIOSUtil sign:reqParams appSecret:_appSecret];
    
    
    NSMutableString *body = [[NSMutableString alloc]init];
    NSURL *url = [NSURL URLWithString:_apiEntryUrl];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url 
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
    
    NSEnumerator *enumerator = [reqParams keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject])) {
        [body appendString:key];        
        [body appendString:@"=" ];
        [body appendString:[reqParams objectForKey:key]];
        [body appendString:@"&" ];
    }
    
    
    NSData *d = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [req setHTTPMethod:method];
    [req setHTTPBody:d];
    
    
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
