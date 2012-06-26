//
//  TopAuthView.m
//  TopIOSSdk
//
//  Created by cenwenchu on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopAuthView.h"

@implementation TopAuthView

@synthesize authView = _authView;
@synthesize target;
@synthesize callback;

-(id) initWithView:(UIWebView *)authView
{
    if((self = [super init]))
    {
        [self setAuthView:authView];    
    }
    
    return self;
}


@end
