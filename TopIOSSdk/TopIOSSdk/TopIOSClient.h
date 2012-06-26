//
//  TopIOSClient.h
//  sdk
//
//  IOS客户端，全局尽量使用一个即可，多个也不冲突，但是会消耗内存，本身支持并发，实现了IOSSdk的两个接口。
//
//
//
//  TopIOSClient iosClient = [[TopIOSClient alloc] initIOSClient:@"xxx" appSecret:@"xxx" callbackUrl:@"xxx" needAutoRefreshToken:TRUE];

//  //授权方法调用，第一个参数就是当前view的viewController
//  [iosClient auth:self];
//
//  //授权完成以后就可以直接调用服务了
//  [iosClient api:false method:@"POST" params:params target:xxx cb:SEL];
//
//
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopIOSSdk.h"
#import "TopAuth.h"

@interface TopIOSClient : NSObject <TopIOSSdk,UIWebViewDelegate>

@property(copy,atomic) NSString *appKey;
@property(copy,atomic) NSString *appSecret;
@property(copy,atomic) NSString *callbackUrl;

//是否需要自动刷新已经授权过的会话，如果授权用户较多不建议使用自动（> 10个）
@property BOOL needAutoRefreshToken;

//初始化ios客户端,需要提供appkey，appsecretcode，回调地址（保持和appkey注册的时候填入的回调地址一级域名一致），是否需要自动刷新access_token（在freshtoken有效期内）
-(id)initIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl needAutoRefreshToken:(BOOL)needAutoRefreshToken;

//通过接口获得内部某一个user_id的授权
-(TopAuth *)getAuthByUserId:(NSString *)user_id;
//通过接口存储内部某一个user_id的授权
-(void)setAuthByUserId:(NSString *)user_id auth:(TopAuth *)auth;
//获得当前所有授权用户的userid
-(NSArray *)getAllAuthUserIds;

//将所有内存中的授权持久化到userdefaults中
-(void)storeAuthPools;
//将持久化的userdefaults中的授权载入内存
-(void)loadAuthPools;

@end
