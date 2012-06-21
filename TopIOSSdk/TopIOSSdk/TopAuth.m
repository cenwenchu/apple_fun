//
//  TopAuth.m
//  TopIOSSdk
//
//  Created by cenwenchu on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopAuth.h"

@implementation TopAuth

@synthesize access_token;
@synthesize refresh_token;
@synthesize mobile_token;
@synthesize token_expire_time;
@synthesize refresh_expire_time;
@synthesize beg_time;
@synthesize refresh_interval;

@synthesize token_expire_time_r1;
@synthesize token_expire_time_r2;
@synthesize token_expire_time_w1;
@synthesize token_expire_time_w2;

@synthesize user_id;
@synthesize user_name;

-(id)initTopAuthFromString:(NSString*) authString
{
    if((self = [super init]))
    {
        if (authString)
        {
            NSArray * chunks = [authString componentsSeparatedByString:@"&"];
            
            beg_time = [NSDate date];
            refresh_interval = 0;
            
            for(NSString* item in chunks)
            {
                if ([item hasPrefix:@"access_token="])
                {
                    [self setAccess_token:[item substringFromIndex:[@"access_token=" length]]];
                    continue;
                }
                
                if ([item hasPrefix:@"refresh_token="])
                {
                    [self setRefresh_token:[item substringFromIndex:[@"refresh_token=" length]]];
                    continue;
                }
                
                if ([item hasPrefix:@"mobile_token="])
                {
                    [self setMobile_token:[item substringFromIndex:[@"mobile_token=" length]]];
                    continue;
                }
                
                if ([item hasPrefix:@"re_expires_in="])
                {
                    [self setRefresh_expire_time: [NSNumber numberWithInt: 
                                                   [[item substringFromIndex:[@"re_expires_in=" length]] intValue]]];
                    continue;
                }
                
                if ([item hasPrefix:@"expires_in="])
                {
                    [self setToken_expire_time: [NSNumber numberWithInt: 
                                                   [[item substringFromIndex:[@"expires_in=" length]] intValue]]];
                    continue;
                }
                
                
                if ([item hasPrefix:@"r1_expires_in="])
                {
                    [self setToken_expire_time_r1: [NSNumber numberWithInt: 
                                                    [[item substringFromIndex:[@"r1_expires_in=" length]] intValue]]];
                    continue;
                }
                
                if ([item hasPrefix:@"r2_expires_in="])
                {
                    [self setToken_expire_time_r2: [NSNumber numberWithInt: 
                                                    [[item substringFromIndex:[@"r2_expires_in=" length]] intValue]]];
                    continue;
                }
                
                if ([item hasPrefix:@"w1_expires_in="])
                {
                    [self setToken_expire_time_w1: [NSNumber numberWithInt: 
                                                    [[item substringFromIndex:[@"w1_expires_in=" length]] intValue]]];
                    continue;
                }
                
                if ([item hasPrefix:@"w2_expires_in="])
                {
                    [self setToken_expire_time_w2: [NSNumber numberWithInt: 
                                                    [[item substringFromIndex:[@"w2_expires_in=" length]] intValue]]];
                    continue;
                }
                
                if ([item hasPrefix:@"taobao_user_id="])
                {
                    [self setUser_id: [item substringFromIndex:[@"taobao_user_id=" length]]];
                    continue;
                }
                
                if ([item hasPrefix:@"taobao_user_nick="])
                {
                    [self setUser_name: [item substringFromIndex:[@"taobao_user_nick=" length]]];
                    continue;
                }
                
            }
            
            if (token_expire_time_r1 && token_expire_time_r1 > 0)
                refresh_interval = token_expire_time_r1;
            if (token_expire_time_r2 && token_expire_time_r2 > 0 && token_expire_time_r2 < refresh_interval)
                refresh_interval = token_expire_time_r2;
            if (token_expire_time_w1 && token_expire_time_w1 > 0 && token_expire_time_w1 < refresh_interval)
                refresh_interval = token_expire_time_w1;
            if (token_expire_time_w2 && token_expire_time_w2 > 0 && token_expire_time_w2 < refresh_interval)
                refresh_interval = token_expire_time_w2;
            
            NSLog(@"refresh seconds : %@ s.",refresh_interval);
            NSLog(@"refresh r1 seconds : %@ s.",token_expire_time_r1);
        }
    }
    
    return self;
    
}

-(void)dealloc
{
    [self setAccess_token:nil];
    [self setRefresh_token:nil];
    [self setMobile_token:nil];
    [self setToken_expire_time:nil];
    [self setRefresh_expire_time:nil];
    [self setBeg_time:nil];
}

@end
