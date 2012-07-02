//
//  Attachment.m
//  TopIOSSdk
//
//  Created by cenwenchu on 12-6-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopAttachment.h"

@implementation TopAttachment

@synthesize name;
@synthesize data;

-(void)dealloc
{
    [self setName:nil];
    [self setData:nil];
}

@end
