//
//  TopIOSClient.h
//  sdk
//
//  IOS客户端，全局尽量使用一个即可，多个也不冲突，但是会消耗内存，本身支持并发，实现了IOSSdk的两个接口。
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
@property(readonly,atomic) TopAuth *topAuth;
@property BOOL needAutoRefreshToken;

//初始化ios客户端,需要提供appkey，appsecretcode，回调地址（保持和appkey注册的时候填入的回调地址一级域名一致），是否需要自动刷新access_token（在freshtoken有效期内）
-(id)initIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl needAutoRefreshToken:(BOOL)needAutoRefreshToken;

@end
