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
    @property(copy,atomic) NSString *authEntryUrl;
    @property(copy,atomic) NSString *apiEntryUrl;
    @property(copy,atomic) NSString *authRefreshEntryUrl;
    @property(copy,atomic) NSString *sysName;
    @property(copy,atomic) NSString *sysVersion;
    @property(copy,atomic) NSString *packageVersion;
    @property(copy,atomic) NSString *packageUUID;

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
@synthesize needAutoRefreshToken = _needAutoRefreshToken;
@synthesize queue;
@synthesize authView;
@synthesize sysName;
@synthesize sysVersion;
@synthesize autoWorker;
@synthesize packageVersion;
@synthesize packageUUID;

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
        
        [self config];
        [self loadAuth];
        
    }
    
    return self;
}

-(void)config
{
    NSMutableDictionary * dict =  [[NSMutableDictionary  alloc] initWithContentsOfFile :@"/sdk-config.plist"] ;
    
    if (dict)
    {
        NSString *pkg_version = [dict objectForKey:@"package_version"];
        NSString *pkg_uuid =  [dict objectForKey : @"package_uuid"];
    
        [self setPackageUUID:pkg_uuid];
        [self setPackageVersion:pkg_version];
    }
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
        int i = ([_topAuth refresh_interval] * 7/10);
        
        NSDate *checkDate = [[_topAuth beg_time] dateByAddingTimeInterval:i];
        
        if([checkDate compare:now] == NSOrderedAscending)
        {
            
            [_topAuth setBeg_time:now];
            
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
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
            [headers setObject:timestamp forKey:@"timestamp"];
            
            NSString * track_id = nil;
            if (_topAuth)
            {
                track_id = [self makeTrackId:[_topAuth user_id] timestamp:timestamp];
            }
            [headers setObject:track_id forKey:@"track_id"];
            [headers setObject:packageVersion forKey:@"packageVersion"];
            
            
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
                    
                    id jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    
                    [_topAuth refresh:jsonObjects];
                    [self storeAuth];
                    
                }
                else if (error != nil){
                    NSLog(@"Error happened = %@", error); 
                }
            }];

            
        }
    }
}

-(void)storeAuth
{
    if(_topAuth)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:[_topAuth access_token] forKey:@"access_token"];
        [defaults setObject:[_topAuth refresh_token] forKey:@"refresh_token"];
        [defaults setObject:[_topAuth mobile_token] forKey:@"mobile_token"];
        [defaults setObject:[NSNumber numberWithInt:[_topAuth token_expire_time]] forKey:@"token_expire_time"];
        [defaults setObject:[NSNumber numberWithInt:[_topAuth refresh_expire_time]] forKey:@"refresh_expire_time"];
        [defaults setObject:[NSNumber numberWithInt:[_topAuth refresh_interval]] forKey:@"refresh_interval"];
        [defaults setObject:[_topAuth beg_time] forKey:@"beg_time"];
        [defaults setObject:[NSNumber numberWithInt:[_topAuth token_expire_time_r1]] forKey:@"token_expire_time_r1"];
        [defaults setObject:[NSNumber numberWithInt:[_topAuth token_expire_time_r2]] forKey:@"token_expire_time_r2"];
        [defaults setObject:[NSNumber numberWithInt:[_topAuth token_expire_time_w1]] forKey:@"token_expire_time_w1"];
        [defaults setObject:[NSNumber numberWithInt:[_topAuth token_expire_time_w2]] forKey:@"token_expire_time_w2"];
        
        [defaults setObject:[_topAuth user_name] forKey:@"user_name"];
        [defaults setObject:[_topAuth user_id] forKey:@"user_id"];
    }
}

-(void)loadAuth
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults valueForKey:@"access_token"])
    {
        [_topAuth setAccess_token:[defaults valueForKey:@"access_token"]];
        [_topAuth setRefresh_token:[defaults valueForKey:@"refresh_token"]];
        [_topAuth setMobile_token:[defaults valueForKey:@"mobile_token"]];
        [_topAuth setBeg_time:[defaults valueForKey:@"beg_time"]];
        [_topAuth setUser_name:[defaults valueForKey:@"user_name"]];
        [_topAuth setUser_id:[defaults valueForKey:@"user_id"]];
        [_topAuth setToken_expire_time:[(NSNumber *)[defaults valueForKey:@"token_expire_time"] intValue]];
        [_topAuth setRefresh_expire_time:[(NSNumber *)[defaults valueForKey:@"refresh_expire_time"] intValue]];
        [_topAuth setRefresh_interval:[(NSNumber *)[defaults valueForKey:@"refresh_interval"] intValue]];
        [_topAuth setToken_expire_time_r1:[(NSNumber *)[defaults valueForKey:@"token_expire_time_r1"] intValue]];
        [_topAuth setToken_expire_time_r2:[(NSNumber *)[defaults valueForKey:@"token_expire_time_r2"] intValue]];
        [_topAuth setToken_expire_time_w1:[(NSNumber *)[defaults valueForKey:@"token_expire_time_w1"] intValue]];
        [_topAuth setToken_expire_time_w2:[(NSNumber *)[defaults valueForKey:@"token_expire_time_w2"] intValue]];
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
    
    [self storeAuth];
    
}

-(NSString *)makeTrackId:(NSString *)user_id timestamp:(NSString *)timestamp
{
    NSMutableString *s = [[NSMutableString alloc] initWithString:_appKey];
    
    [s appendString:@"-"];
    [s appendString:_appSecret];
    [s appendString:@"-"];
    [s appendString:packageUUID];
    [s appendString:@"-"];
    [s appendString:timestamp];
    
    if(user_id)
    {
        [s appendString:@"-"];
        [s appendString:user_id];
    }
    
    
    NSString *trackId = [s MD5EncodedString];
    
    return trackId;
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
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    [reqParams setObject:timestamp forKey:@"timestamp"];
    
    if (_topAuth)
        [reqParams setObject:[_topAuth access_token]  forKey:@"session"];
    
    if (sysVersion)
        [headers setObject:sysVersion forKey:@"client_sysVersion"];
        
    if (sysName)
        [headers setObject:sysName forKey:@"client_sysName"];
    
    NSString * track_id = nil;
    
    if (_topAuth)
    {
        track_id = [self makeTrackId:[_topAuth user_id] timestamp:timestamp];
    }
    else {
        track_id = [self makeTrackId:nil timestamp:timestamp];
    }
    
    [headers setObject:track_id forKey:@"track_id"];
    [headers setObject:timestamp forKey:@"timestamp"];
    [headers setObject:packageVersion forKey:@"packageVersion"];


    
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
