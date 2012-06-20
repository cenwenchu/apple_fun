//
//  TBViewController.h
//  DemoShow
//
//  Created by cenwenchu on 12-6-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBViewController : UIViewController<UITextFieldDelegate,NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIWebView *contentView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendRequestButton;

@property (weak, nonatomic) IBOutlet UITextField *destTextField;
@property (weak, nonatomic) IBOutlet UILabel *contentView2;

@end
