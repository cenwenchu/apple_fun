//
//  TopIOSClient.m
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopIOSClient.h"
#import "TopIOSUtil.h"
#import "TopAuthView.h"


@interface TopIOSClient()
    @property(copy,atomic) NSString *authEntryUrl;
    @property(copy,atomic) NSString *apiEntryUrl;
    @property(copy,atomic) NSString *authRefreshEntryUrl;
    @property(copy,atomic) NSString *tqlEntryUrl;

    @property(copy,atomic) NSString *sysName;
    @property(copy,atomic) NSString *sysVersion;
    @property(copy,atomic) NSString *packageVersion;
    @property(copy,atomic) NSString *packageUUID;

    @property NSOperationQueue *queue;
    //授权展示页面
    @property(strong,nonatomic)TopAuthView *topAuthView;
    //后台自动刷新授权，当前为单线程处理所有的授权，如果授权数量很多会不太适合
    @property NSTimer *autoRefreshTokenWorker;
    //存储授权的缓存
    @property(copy,atomic) NSMutableDictionary *authPool;
    @property Boolean isAuthPoolUpdate;


-(id)initIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl needAutoRefreshToken:(BOOL)needAutoRefreshToken;

@end


static NSMutableDictionary *clientPools;

@implementation TopIOSClient

//app config
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize callbackUrl = _callbackUrl;
@synthesize authPool;
@synthesize needAutoRefreshToken = _needAutoRefreshToken;

//sys config
@synthesize authEntryUrl = _authEntryUrl;
@synthesize apiEntryUrl = _apiEntryUrl;
@synthesize authRefreshEntryUrl = _authRefreshEntryUrl;
@synthesize tqlEntryUrl = _tqlEntryUrl;

//sys component
@synthesize queue;
@synthesize topAuthView;
@synthesize autoRefreshTokenWorker;
@synthesize isAuthPoolUpdate;

//client config
@synthesize sysName;
@synthesize sysVersion;
@synthesize packageVersion;
@synthesize packageUUID;


//注册不同的appkey的ios客户端,需要提供appkey，appsecretcode，回调地址（保持和appkey注册的时候填入的回调地址一级域名一致），是否需要自动刷新access_token（在freshtoken有效期内）
+(id)registerIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl needAutoRefreshToken:(BOOL)needAutoRefreshToken
{
    if(!clientPools)
    {
        clientPools = [[NSMutableDictionary alloc] init];
    }
    
    TopIOSClient *client = [[TopIOSClient alloc]initIOSClient:appKey appSecret:appSecret callbackUrl:callbackUrl needAutoRefreshToken:needAutoRefreshToken];
    
    [clientPools setObject:client forKey:appKey];
    
    return client;
}

//根据appkey获得客户端，如果没有注册将得到nil
+(TopIOSClient *)getIOSClientByAppKey:(NSString *)appKey
{
    if (clientPools)
    {
        return [clientPools objectForKey:appKey];
    }
    else {
        return nil;
    }
}

-(id)initIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl needAutoRefreshToken:(BOOL)needAutoRefreshToken
{
    if(self = [super init])
    {
        [self setAuthEntryUrl:@"https://oauth.taobao.com/authorize"];
        //[self setAuthEntryUrl:@"https://oauth.daily.taobao.net/authorize"];
        [self setApiEntryUrl:@"http://gw.api.taobao.com/router/rest"];  
        //[self setApiEntryUrl:@"http://10.232.127.145/router/rest"];
        [self setAuthRefreshEntryUrl:@"https://oauth.taobao.com/token"];
        [self setTqlEntryUrl:@"http://gw.api.taobao.com/tql/2.0/json"];
        [self setAppKey:appKey];
        [self setAppSecret:appSecret];
        [self setCallbackUrl:callbackUrl];
        [self setNeedAutoRefreshToken:needAutoRefreshToken];
        
        [self setSysName:[[UIDevice currentDevice] systemName]];
        [self setSysVersion:[[UIDevice currentDevice] systemVersion]];
        
        if(needAutoRefreshToken)
            autoRefreshTokenWorker = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refreshAllToken) userInfo:nil repeats:true];
        
        queue = [[NSOperationQueue alloc] init];
        authPool = [[NSMutableDictionary alloc]init];
        isAuthPoolUpdate = false;
        
        UIWebView *_authView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        [_authView setDelegate:self];
        [_authView setScalesPageToFit:YES];
        [_authView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        
        [self setTopAuthView:[[TopAuthView alloc]initWithView:_authView]];
        
        [self config];
        [self loadAuthPools];
        
    }
    
    return self;
}

-(void)config
{
    //由于static library无法带有文件，因此暂时先写入
    [self setPackageUUID:@"1Bxdwylyb8*(gxhw"];
    [self setPackageVersion:@"top_ios_version_2012_0.1"];
}

-(void)storeAuthPools 
{
    if([authPool count] > 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"authPools"])
            [defaults removeObjectForKey:@"authPools"];
        
        NSMutableDictionary *as = [[NSMutableDictionary alloc]init];
        
        for(NSString *k in [authPool allKeys])
        {
            [as setObject:[[authPool objectForKey:k] encodeTopAuthToString] forKey:k];
        }
        
        [defaults setObject:as forKey:@"authPools"];
        
    }
}


-(void)loadAuthPools
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
       
    if ([defaults objectForKey:@"authPools"])
    {
        [authPool removeAllObjects];
        
        
        NSMutableDictionary *ar = [defaults objectForKey:@"authPools"];
        
        for(NSString * t in [ar allValues])
        {
            TopAuth *auth = [[TopAuth alloc]initTopAuthFromString:t]; 
            [authPool setObject:auth forKey:[auth user_id]]; 
        }
    }
    
}

-(NSArray *)getAllAuthUserIds
{
    if(authPool && [authPool count] > 0)
    {
        return [authPool allKeys];
    }
    else {
        return nil;
    }
}

-(NSArray *)getAllAuthUserNames
{
    if(authPool && [authPool count] > 0)
    {
        NSMutableArray *names = [[NSMutableArray alloc] init];
        
        for(TopAuth *t in [authPool allValues])
        {
            [names addObject:[t user_name]];
        }
        
        return names;
        
    }
    else {
        return nil;
    }
}

-(TopAuth *)getAuthByUserId:(NSString *)user_id
{
    return [authPool objectForKey:user_id];
}

-(void)setAuthByUserId:(NSString *)user_id auth:(TopAuth *)auth
{
    if (auth)
    {
        [authPool setObject:authPool forKey:user_id];
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
    [[self topAuthView] setAuthView:nil];
    [self setTopAuthView:nil];
    [self setSysVersion:nil];
    [self setSysName:nil];
    [self setPackageVersion:nil];
    [self setPackageUUID:nil];
    [self setTqlEntryUrl:nil];
    authPool = nil;
    
    if (_needAutoRefreshToken)
    {
        [autoRefreshTokenWorker invalidate];
        [self setAutoRefreshTokenWorker:nil];
    }

}

-(void)refreshAllToken
{
    NSArray *tokens = [authPool allValues];
    
    for(TopAuth *t in tokens)
    {
        [self refreshToken:t];
    }
    
}

-(void)refreshTokenByUserId:(NSString *)userId
{
    if([authPool objectForKey:userId])
    {
        [self refreshToken:[authPool objectForKey:userId]];
    }
}

-(void)refreshToken:(TopAuth *)topAuth
{
    if(topAuth && [topAuth refresh_interval] > 0)
    {
        NSDate *now = [NSDate date];
        int i = ([topAuth refresh_interval] * 7/10);
        
        NSDate *checkDate = [[topAuth beg_time] dateByAddingTimeInterval:i];
        
        if([checkDate compare:now] == NSOrderedAscending)
        {
            
            [topAuth setBeg_time:now];
            
            NSMutableDictionary *reqParams = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
            
            
            [reqParams setObject:_appKey forKey:@"client_id"];
            [reqParams setObject:_appSecret forKey:@"client_secret"];
            [reqParams setObject:@"refresh_token" forKey:@"grant_type"];
            [reqParams setObject:[topAuth refresh_token] forKey:@"refresh_token"];
            
            NSLog(@" token userId: %@",[topAuth user_id]);
            
            if (sysVersion)
                [headers setObject:sysVersion forKey:@"client_sysVersion"];
            
            if (sysName)
                [headers setObject:sysName forKey:@"client_sysName"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
            [headers setObject:timestamp forKey:@"timestamp"];
            
            NSString * track_id = nil;
            if (topAuth)
            {
                track_id = [self makeTrackId:[topAuth user_id] timestamp:timestamp];
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
                    
                    NSString *uid = [jsonObjects objectForKey:@"taobao_user_id"];
                    
                    TopAuth *ta = [authPool objectForKey:uid];
                    
                    if (ta)
                    {
                        [ta refresh:jsonObjects];
                        isAuthPoolUpdate = true;
                        [self storeAuthPools];
                    }
                    
                }
                else if (error != nil){
                    NSLog(@"Error happened = %@", error); 
                }
            }];

            
        }
    }
}


-(void)auth:(id)target cb:(SEL)cb
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
    
    [[self topAuthView] setCallback:cb];
    [[self topAuthView] setTarget:target];
    [[[self topAuthView] authView] loadRequest:req];
    [self showAuthView];
}

-(TopAuth *)oauthCallback:(NSString *)authString
{
    
    TopAuth *topAuth = [[TopAuth alloc] initTopAuthFromString:authString];  
    
    NSString *uid = [topAuth user_id];
    
    if([authPool objectForKey:uid])
    {
        [authPool removeObjectForKey:uid];
    }
    
    [authPool setObject:topAuth forKey:uid];
    
    isAuthPoolUpdate = true;
    
    [self storeAuthPools];
    
    return topAuth;
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

-(void)api:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb userId:(NSString *)userId
{
    [self call:_apiEntryUrl method:method params:params target:target cb:cb userId:userId];
}

-(void)tql:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb userId:(NSString *)userId
{
    [self call:_tqlEntryUrl method:method params:params target:target cb:cb userId:userId];
}

-(void)call:(NSString *)url method:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb userId:(NSString *)userId
{
    NSMutableDictionary *reqParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    Boolean isMultipart = [self prepareRequest:params reqParams:reqParams files:files headers:headers userId:userId];
    
    
    NSMutableString *body = [[NSMutableString alloc]init];
    
    NSEnumerator *enumerator = [reqParams keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject])) {
        [body appendString:key];        
        [body appendString:@"=" ];
        [body appendString:[[reqParams objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [body appendString:@"&" ];
    }
    
    NSMutableURLRequest *req = nil;
    
    if ([method caseInsensitiveCompare:@"Get"] == NSOrderedSame)
    {
        NSString *_url = [url stringByAppendingString:@"?"];
        _url = [_url stringByAppendingString:body];
        
        NSLog(@"%@",_url);
        
        req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: _url] 
                                      cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
        
    }
    else {
        req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] 
                                      cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
        
        if (!isMultipart)
        {
            NSData *d = [body dataUsingEncoding:NSUTF8StringEncoding];
            [req setHTTPBody:d];
        }
        else {
            [TopIOSUtil setMultipartPostBody:req reqParams:reqParams attachs:files];
        }
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

-(Boolean)prepareRequest:(NSDictionary *)params reqParams:(NSMutableDictionary *)reqParams files:(NSMutableDictionary *)files headers:(NSMutableDictionary *) headers userId:(NSString *)userId
{
    Boolean isMultipart = false;
    
    NSArray *keys = [params allKeys];
    
    for(id k in keys)
    {
        id v = [params objectForKey:k];
        
        if ([v isKindOfClass:[Attachment class]])
        {
            isMultipart = true;
            [files setObject:v forKey:k];
        }
        else {
            [reqParams setObject:v forKey:k];
        }
    }
    
    if (![reqParams objectForKey:@"format"])
        [reqParams setObject:@"json" forKey:@"format"];
    
    if (_appKey)
        [reqParams setObject:_appKey forKey:@"app_key"];
    
    [reqParams setObject:@"2.0" forKey:@"v"];
    [reqParams setObject:@"md5" forKey:@"sign_method"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    [reqParams setObject:timestamp forKey:@"timestamp"];
    
    if (userId && [authPool objectForKey:userId])
        [reqParams setObject:[[authPool objectForKey:userId] access_token]  forKey:@"session"];
    else {
        [reqParams setObject:[params objectForKey:@"session" ] forKey:@"session"];
    }
    
    if (sysVersion)
        [headers setObject:sysVersion forKey:@"client_sysVersion"];
    
    if (sysName)
        [headers setObject:sysName forKey:@"client_sysName"];
    
    NSString * track_id = nil;
    
    if (userId && [authPool objectForKey:userId])
    {
        track_id = [self makeTrackId:userId timestamp:timestamp];
    }
    else {
        track_id = [self makeTrackId:nil timestamp:timestamp];
    }
    
    [headers setObject:track_id forKey:@"track_id"];
    [headers setObject:timestamp forKey:@"timestamp"];
    [headers setObject:packageVersion forKey:@"packageVersion"];
    
    
    [TopIOSUtil sign:reqParams appSecret:_appSecret];
    
    return isMultipart;
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
            
            TopAuth* ta = [self oauthCallback:(NSString *)anObject];
            [self hideAuthView];
            
            [[topAuthView target] performSelectorOnMainThread:[topAuthView callback] withObject:ta waitUntilDone:FALSE];
            
            break;
        }
    }
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@",[request URL]);
    return YES;
}


//authView show or hide
- (void)showAuthView
{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window)
    {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
  	[window addSubview:[topAuthView authView]];

}

- (void)hideAuthView
{ 
    [[topAuthView authView] removeFromSuperview];
}

@end
