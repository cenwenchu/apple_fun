//
//  TopAuthView.h
//  TopIOSSdk
//
//  Created by cenwenchu on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopAuthView : NSObject

@property(strong,nonatomic) UIWebView *authView;
@property(strong,nonatomic) id target;
@property SEL callback;

-(id) initWithView:(UIWebView *)authView;

@end
