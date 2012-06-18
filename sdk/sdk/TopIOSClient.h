//
//  TopIOSClient.h
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopIOSSdk.h"
#import "TopUtil.h"
#import "TopConstants.h"

@interface TopIOSClient : NSObject <TopIOSSdk>


@property(copy,atomic) NSString *appKey;
@property(copy,atomic) NSString *appSecret;
@property(copy,atomic) NSString *redirectURI;
@property(copy,atomic) NSString *accessToken;

@property(copy,atomic) NSString *authEntryUrl;
@property(copy,atomic) NSString *apiEntryUrl;

-(id)initWithEntryUrl:(NSString *)authurl apiurl:(NSString *)apiurl appKey:(NSString *)appKey appSecret:(NSString *)appSecret;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;
+ (NSString *)stringFromDictionary:(NSDictionary *)dict;


@end
