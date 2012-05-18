//
//  TIDViewController.m
//  welcome
//
//  Created by a p p le on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TIDViewController.h"

@interface TIDViewController ()

@end

@implementation TIDViewController
@synthesize MyLabel;
@synthesize MyText;
@synthesize helloButton;
@synthesize userName = _userName;

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.MyText) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setHelloButton:nil];
    [self setMyLabel:nil];
    [self setMyText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [helloButton release];
    [MyLabel release];
    [MyText release];
    [super dealloc];
}
- (IBAction)changeGreeting:(id)sender {
    _userName = MyText.text;
    
    if ([_userName length] == 0) {
        _userName = @"World";
    }
    
    NSString *greeting = [[NSString alloc] initWithFormat:@"Hello, %@!", _userName];
    MyLabel.text = greeting;
}
@end
