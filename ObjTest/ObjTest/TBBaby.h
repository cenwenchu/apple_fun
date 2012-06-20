//
//  TBBaby.h
//  ObjTest
//
//  Created by a p p le on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBBaby : NSObject

    
    @property(copy,readwrite) NSString *father;
    @property(copy,readwrite) NSString *mather;
    @property(copy,readwrite) NSString *name;

    @property(readwrite) int weight;
    @property(readwrite) int height;
    
    -(void)say;
    -(void)cry;
    -(void)eat:(NSString *) food;
    -(void)grow:(int) weight height:(int)height;
    

@end
