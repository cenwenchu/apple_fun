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
#import "TopAuth.h"


@protocol TopIOSSdk <NSObject>

//授权接口，直接封装了授权的页面和授权返回解析保存,当前暂时支持成功授权返回TopAuth对象，失败场景后续支持
-(void)auth:(id)target cb:(SEL)cb;

//刷新授权access_token，指定刷新某一个用户的授权会话
-(void)refreshTokenByUserId:(NSString *)userId;

//调用api入口:  method请求的方法(GET,POST);params具体的业务和系统参数(可以不传，内部会有默认设置，如果要修改比如返回格式，可以设置);target和cb用于请求后传递结果回调（NSString或者NSError两种返回）
//userid如果传入，则可以根据授权状况自动选择不同的用户授权来请求服务，具体业务参看：http://open.taobao.com/doc/category_list.htm?id=102 
-(void)api:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb userId:(NSString *)userId;

//调用tql的入口，method请求的方法(GET,POST);params具体的业务和系统参数;target和cb用于请求后传递结果回调（NSString或者NSError两种返回）
//userid如果传入，则可以根据授权状况自动选择不同的用户授权来请求服务，具体使用参看 http://open.taobao.com/doc/category_list.htm?id=143
-(void)tql:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb userId:(NSString *)userId;


@end
