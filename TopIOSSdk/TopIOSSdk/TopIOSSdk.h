//
//  TopIOSSdk.h
//  sdk
//
//  IOS的最基本两个操作接口：授权和发起服务请求。
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TopIOSSdk <NSObject>

//授权接口，直接封装了授权的页面和授权返回解析保存
-(void)auth:(UIViewController *) currentViewController;


//调用api: isHttps是否采用https的方式请求api; method请求的方法(GET,POST);params具体的业务和系统参数;target和cb用于请求后传递结果回调（NSString或者NSError两种返回）
-(void)api:(BOOL)isHttps method:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb;

@end
