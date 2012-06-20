//
//  TopIOSClient.h
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopIOSSdk.h"

@interface TopIOSClient : NSObject <TopIOSSdk,UIWebViewDelegate>

-(id)initIOSClient:(NSString *)appKey appSecret:(NSString *)appSecret callbackUrl:(NSString *)callbackUrl;
-(void)oauthCallback:(NSString *)access_token;

@end
