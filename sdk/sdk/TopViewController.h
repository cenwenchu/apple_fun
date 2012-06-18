//
//  TopViewController.h
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopAppDelegate.h"
#import "TopIOSClient.h"
#import "TopConstants.h"
#import "TopAuthViewController.h"

@interface TopViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *reqTextField;
@property (weak, nonatomic) IBOutlet UIButton *reqButton;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UITextView *responseContentView;
@property (weak, nonatomic) IBOutlet UILabel *messageAlertLabel;

@end
