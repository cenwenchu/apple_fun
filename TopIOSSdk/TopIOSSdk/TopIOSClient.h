//
//  TopIOSClient.h
//  sdk
//
//  IOS客户端，全局一个appkey使用一个，只需要注册就可以创建全局单例。
//
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopIOSSdk.h"
#import "TopAuth.h"
#import "Attachment.h"

@interface TopIOSClient : NSObject <TopIOSSdk,UIWebViewDelegate>

@property(copy,atomic) NSString *appKey;
@property(copy,atomic) NSString *appSecret;
@property(copy,atomic) NSString *callbackUrl;

//是否需要自动刷新已经授权过的会话，如果授权用户较多不建议使用自动（> 10个）
@property BOOL needAutoRefreshToken;

//注册不同的appkey的ios客户端,需要提供appkey，appsecretcode，回调地址（保持和appkey注册的时候填入的回调地址一级域名一致），是否需要自动刷新access_token（在freshtoken有效期内）
+(id)registerIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl needAutoRefreshToken:(BOOL)needAutoRefreshToken;

//根据appkey获得客户端，如果没有注册将得到nil
+(TopIOSClient *)getIOSClientByAppKey:(NSString *)appKey;

//通过接口获得内部某一个user_id的授权
-(TopAuth *)getAuthByUserId:(NSString *)user_id;
//通过接口存储内部某一个user_id的授权
-(void)setAuthByUserId:(NSString *)user_id auth:(TopAuth *)auth;


//获得当前所有授权用户的授权信息
-(NSArray *)getAllAuths;

//将所有内存中的授权持久化到userdefaults中,默认自动会持久化，不需要调用
-(void)storeAuthPools;
//将持久化的userdefaults中的授权载入内存，client启动的时候会被调用一次
-(void)loadAuthPools;

@end
