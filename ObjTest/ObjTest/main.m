//
//  main.m
//  ObjTest
//
//  Created by a p p le on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TBBaby.h"

int main(int argc, char *argv[])
{
//    TBBaby *baby = [[TBBaby alloc]init];
//    
//    [baby setName:@"cenxiao"];
//    [baby setFather:@"cenwenchu"];
//    [baby setMather:@"bufan"];
//    
//    [baby cry];
//    [baby eat:@"milk"];
//    [baby say];
//    [baby grow:10 height:20];
//    [baby say];
    
     @autoreleasepool {
//         id url = [NSURL URLWithString:@"http://media.tumblr.com/tumblr_m0xucu8s1Q1r3cx40.jpg"];
//         id image= [[NSImage alloc] initWithContentsOfURL:url];
//         id tiff = [image TIFFRepresentation];
//    
//         [tiff writeToFile:@"/Users/apple/apple.jpg" atomically:YES];
//         
//         NSLog(@"got image now!");
//         
//        #define MAX_BIG 1000
//         
//         int test = 100;
//        
//         if(test > MAX_BIG)
//         {
//             NSLog(@"test big than max");
//         }
//         else {
//             NSLog(@"test small than max");
//         }
//         
//         enum fruit {
//             apple  = 1,
//             banana = 2
//         };
//         
//         printf("fruit is %i",apple);
//         
         
         id request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gw.api.taobao.com/rest"]
                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                   timeoutInterval:60.0];
         
         NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:nil];
         
         if (connection)
         {
             id receiveData = [[NSMutableData data] retain];
         }
         
         
         
     }
    
    return 0;
    
}
