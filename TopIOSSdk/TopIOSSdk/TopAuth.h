//
//  TopAuth.h
//  TopIOSSdk
//
//  Created by cenwenchu on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopAuth : NSObject

@property(copy,nonatomic) NSString *access_token;
@property(copy,nonatomic) NSString *refresh_token;
@property(copy,nonatomic) NSString *mobile_token;
@property(copy,nonatomic) NSNumber *token_expire_time;
@property(copy,nonatomic) NSNumber *refresh_expire_time; 
@property(copy,nonatomic) NSDate *create_time; 

@property(copy,nonatomic) NSNumber *token_expire_time_r1;
@property(copy,nonatomic) NSNumber *token_expire_time_r2;
@property(copy,nonatomic) NSNumber *token_expire_time_w1;
@property(copy,nonatomic) NSNumber *token_expire_time_w2;

@property(copy,nonatomic) NSString *user_name;
@property(copy,nonatomic) NSString *user_id;

-(id)initTopAuthFromString:(NSString*) authString;

@end
