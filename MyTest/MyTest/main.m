//
//  main.m
//  MyTest
//
//  Created by cenwenchu on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TopAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
//    NSString *u = @"http://gw.api.taobao.com/router/rest?fields=nick,alipay_account&sign_method=md5&format=json&app_key=12131533&session=61008245297e22320ecd74a51148647f188fb03bf62b28724006395&v=2.0&track_id=A2C4C0A8BB0FF15289238DC84886B9E6&method=taobao.user.get&timestamp=2012-06-21";
        
    NSString *u = @"http://gw.api.taobao.com/router/rest?fields=nick,alipay_account&sign_method=md5&format=json&app_key=12131533&session=610210041c78c3f0f4383e08057f66771299588735eada424006395&v=2.0&track_id=A2C4C0A8BB0FF15289238DC84886B9E6&method=taobao.user.get&sign=6AA2A8A6416C3304DA42EEA50A38D87C&";
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: u] 
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
    
    [req setHTTPMethod:@"GET"];
     NSOperationQueue   *queue = [[NSOperationQueue alloc] init];
        
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *resp,NSData *data,NSError *error){
        
        if (error == nil)
        {
            NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error); 
            
        }
    }];
    
    [NSThread sleepForTimeInterval:10];
    
    }
    
    return 0;
}

