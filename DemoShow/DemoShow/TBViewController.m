//
//  TBViewController.m
//  DemoShow
//
//  Created by cenwenchu on 12-6-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TBViewController.h"

@interface TBViewController ()

    @property NSMutableData *receiveData;

@end

@implementation TBViewController

@synthesize backButton;
@synthesize forwardButton;
@synthesize contentView;
@synthesize sendRequestButton;
@synthesize destTextField;
@synthesize contentView2;
@synthesize receiveData;


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.destTextField) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (IBAction)sendRequestBtnAction:(id)sender {
    if( sender == sendRequestButton && [destTextField hasText])
    {
        NSLog(@"%@",[destTextField text]);
        
        if (!receiveData)
        {
            receiveData = [NSMutableData data];
        }
        
        NSURL *url = [NSURL URLWithString:[destTextField text]];
        
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        
        [NSURLConnection connectionWithRequest:req delegate:self];
        
    }
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error message: %@",error);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"receive data length : %i", data.length);
    [receiveData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receiveData setLength:0];
    contentView2.text = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"end response.");
    [contentView2 setText:[[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://m.taobao.com"]];
    
    [contentView loadRequest:req];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setContentView:nil];
    [self setDestTextField:nil];
    [self setReceiveData:nil];
    [self setContentView2:nil];
    [self setSendRequestButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


@end
