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
                    [self setRefresh_expire_time:[[item substringFromIndex:[@"re_expires_in=" length]] intValue]];
                    continue;
                }
                
                if ([item hasPrefix:@"expires_in="])
                {
                    [self setToken_expire_time: [[item substringFromIndex:[@"expires_in=" length]] intValue]];
                    continue;
                }
                
                
                if ([item hasPrefix:@"r1_expires_in="])
                {
                    [self setToken_expire_time_r1:[[item substringFromIndex:[@"r1_expires_in=" length]] intValue]];
                    continue;
                }
                
                if ([item hasPrefix:@"r2_expires_in="])
                {
                    [self setToken_expire_time_r2:[[item substringFromIndex:[@"r2_expires_in=" length]] intValue]];
                    continue;
                }
                
                if ([item hasPrefix:@"w1_expires_in="])
                {
                    [self setToken_expire_time_w1:[[item substringFromIndex:[@"w1_expires_in=" length]] intValue]];
                    continue;
                }
                
                if ([item hasPrefix:@"w2_expires_in="])
                {
                    [self setToken_expire_time_w2:[[item substringFromIndex:[@"w2_expires_in=" length]] intValue]];
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
            
            if (token_expire_time_r1 > 0)
                refresh_interval = token_expire_time_r1;
            if (token_expire_time_r2 > 0 && token_expire_time_r2 < refresh_interval)
                refresh_interval = token_expire_time_r2;
            if (token_expire_time_w1 > 0 && token_expire_time_w1 < refresh_interval)
                refresh_interval = token_expire_time_w1;
            if (token_expire_time_w2 > 0 && token_expire_time_w2 < refresh_interval)
                refresh_interval = token_expire_time_w2;
            
            NSLog(@"refresh interval seconds : %i s.",refresh_interval);
            NSLog(@"refresh r1 seconds : %i s.",token_expire_time_r1);
            NSLog(@"refresh r2 seconds : %i s.",token_expire_time_r2);
            NSLog(@"refresh w1 seconds : %i s.",token_expire_time_w1);
            NSLog(@"refresh w2 seconds : %i s.",token_expire_time_w2);
            NSLog(@"refresh seconds : %i s.",refresh_expire_time);
            
        }
    }
    
    return self;
    
}

-(NSString *)encodeTopAuthToString
{
    NSMutableString * authString = [[NSMutableString alloc]init];
    
    [authString appendFormat:@"access_token=%@",access_token];
    [authString appendFormat:@"&refresh_token=%@",refresh_token];
    [authString appendFormat:@"&re_expires_in=%i",refresh_expire_time];
    [authString appendFormat:@"&expires_in=%i",token_expire_time];
    [authString appendFormat:@"&r1_expires_in=%i",token_expire_time_r1];
    [authString appendFormat:@"&r2_expires_in=%i",token_expire_time_r2];
    [authString appendFormat:@"&w1_expires_in=%i",token_expire_time_w1];
    [authString appendFormat:@"&w2_expires_in=%i",token_expire_time_w2];
    [authString appendFormat:@"&taobao_user_id=%@",user_id];
    [authString appendFormat:@"&taobao_user_nick=%@",user_name];
    
    
    return authString;
}

-(void)refresh:(NSMutableDictionary *) params
{
    NSArray *keys = [params allKeys];
    
    for(NSString *k in keys)
    {
        if ([k isEqualToString: @"access_token"])
        {
            [self setAccess_token:[params objectForKey:k]];
            continue;
        }
        
        if ([k isEqualToString: @"refresh_token"])
        {
            [self setRefresh_token:[params objectForKey:k]];
            continue;
        }
        
        if ([k isEqualToString: @"re_expires_in"])
        {
            [self setRefresh_expire_time:[[params objectForKey:k] intValue]];
            continue;
        }
        
        if ([k isEqualToString: @"expires_in"])
        {
            [self setToken_expire_time:[[params objectForKey:k] intValue]];
            continue;
        }
        
        if ([k isEqualToString: @"r1_expires_in"])
        {
            [self setToken_expire_time_r1:[[params objectForKey:k] intValue]];
            continue;
        }
        
        if ([k isEqualToString: @"r2_expires_in"])
        {
            [self setToken_expire_time_r2:[[params objectForKey:k] intValue]];
            continue;
        }
        
        if ([k isEqualToString: @"w1_expires_in"])
        {
            [self setToken_expire_time_w1:[[params objectForKey:k] intValue]];
            continue;
        }
        
        if ([k isEqualToString: @"w2_expires_in"])
        {
            [self setToken_expire_time_w2:[[params objectForKey:k] intValue]];
            continue;
        }
        
        if ([k isEqualToString: @"taobao_user_id"])
        {
            [self setUser_id:[params objectForKey:k]];
            continue;
        }
        
        if ([k isEqualToString: @"taobao_user_nick"])
        {
            [self setUser_name:[params objectForKey:k]];
            continue;
        }

        
    }
    
    
    if (token_expire_time_r1 > 0)
        refresh_interval = token_expire_time_r1;
    if (token_expire_time_r2 > 0 && token_expire_time_r2 < refresh_interval)
        refresh_interval = token_expire_time_r2;
    if (token_expire_time_w1 > 0 && token_expire_time_w1 < refresh_interval)
        refresh_interval = token_expire_time_w1;
    if (token_expire_time_w2 > 0 && token_expire_time_w2 < refresh_interval)
        refresh_interval = token_expire_time_w2;
    
    NSLog(@"refresh interval seconds : %i s.",refresh_interval);
    NSLog(@"refresh r1 seconds : %i s.",token_expire_time_r1);
    NSLog(@"refresh r2 seconds : %i s.",token_expire_time_r2);
    NSLog(@"refresh w1 seconds : %i s.",token_expire_time_w1);
    NSLog(@"refresh w2 seconds : %i s.",token_expire_time_w2);
    NSLog(@"refresh seconds : %i s.",refresh_expire_time);
    
}

-(void)dealloc
{
    [self setAccess_token:nil];
    [self setRefresh_token:nil];
    [self setMobile_token:nil];
    [self setBeg_time:nil];
    [self setUser_id:nil];
    [self setUser_name:nil];
}

@end
