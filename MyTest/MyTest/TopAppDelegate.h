//
//  TopAppDelegate.h
//  MyTest
//
//  Created by cenwenchu on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TopAppDelegate : NSObject <NSApplicationDelegate,NSURLConnectionDelegate>

@property (assign) IBOutlet NSWindow *window;
@property NSMutableData *data;

- (id)initDelegate;

@end
