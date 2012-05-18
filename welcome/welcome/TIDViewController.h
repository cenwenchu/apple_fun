//
//  TIDViewController.h
//  welcome
//
//  Created by a p p le on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIDViewController : UIViewController <UITextFieldDelegate>
- (IBAction)changeGreeting:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *MyLabel;
@property (retain, nonatomic) IBOutlet UITextField *MyText;
@property (retain, nonatomic) IBOutlet UIButton *helloButton;
@property (copy, nonatomic) NSString *userName;

@end
