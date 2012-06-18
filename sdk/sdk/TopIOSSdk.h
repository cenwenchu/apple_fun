//
//  TopIOSSdk.h
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TopIOSSdk <NSObject>

-(void)auth:(UIWebView *) authView;
-(void)api:(NSString *)type method:(NSString *)method params:(NSDictionary *)params target:(id)target cb:(SEL)cb;

@end
