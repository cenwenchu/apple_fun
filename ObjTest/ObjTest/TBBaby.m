//
//  TBBaby.m
//  ObjTest
//
//  Created by a p p le on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TBBaby.h"

@implementation TBBaby

@synthesize name,height,weight;
@synthesize father;
@synthesize mather;

-(void)say
{
    NSLog(@"my fater %@ ,my mother %@,my name %@,height %d,weigth %d",father,mather,name,height,weight);
}

-(void)cry
{
    NSLog(@"cry!"); 
}

-(void)eat:(NSString *) food
{
    NSLog(@"i eat %@",food);
}


-(void)grow:(int)w height:(int)h
{
    self.weight += w;
    self.height += h;
}

@end
