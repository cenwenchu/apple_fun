//
//  TopAuthViewController.h
//  sdk
//
//  Created by cenwenchu on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TopIOSClient.h"
#import "TopConstants.h"
#import "TopAppDelegate.h"

@interface TopAuthViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *authWebView;
@property (copy, atomic) NSString *command;


@end
