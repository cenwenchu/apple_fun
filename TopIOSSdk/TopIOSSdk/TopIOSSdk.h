//
//  TopIOSSdk.h
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TopIOSSdk <NSObject>

//授权接口
-(void)auth:(UIViewController *) currentViewController;
//调用api
-(void)api:(BOOL)isHttps method:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb;

@end
