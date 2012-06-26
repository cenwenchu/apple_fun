//
//  TopAuth.h
//  TopIOSSdk
//   
//  授权对象，一个TopIOSclient内置一个授权对象，当调用auth接口成功后，授权信息都会保存到对象中，
//  用于服务调用。
//
//  Created by cenwenchu on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopAuth : NSObject

@property(copy,nonatomic) NSString *access_token;
@property(copy,nonatomic) NSString *refresh_token;
@property(copy,nonatomic) NSString *mobile_token;
@property int token_expire_time;
@property int refresh_expire_time; 
@property int refresh_interval;
@property(copy,nonatomic) NSDate *beg_time; 

@property int token_expire_time_r1;
@property int token_expire_time_r2;
@property int token_expire_time_w1;
@property int token_expire_time_w2;

@property(copy,nonatomic) NSString *user_name;
@property(copy,nonatomic) NSString *user_id;

//通过授权返回的字符串初始化授权对象
-(id)initTopAuthFromString:(NSString*) authString;

//更新授权内容
-(void)refresh:(NSMutableDictionary *) params;

//将TopAuth对象序列化为字符串
-(NSString *)encodeTopAuthToString;

@end
