//
//  TopViewController.m
//  sdk
//
//  Created by cenwenchu on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopViewController.h"


@interface TopViewController ()

@end

@implementation TopViewController

@synthesize reqTextField;
@synthesize reqButton;
@synthesize authButton;
@synthesize responseContentView;



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.reqTextField) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (IBAction)authAction:(id)sender {
    TopIOSClient *iosClient = [TopAppDelegate getInnerClient];
    [iosClient auth:self];
}

- (IBAction)sendRequestAction:(id)sender {
   
    [responseContentView setText:nil];
    
    NSString *requestStr = reqTextField.text;
    
    if (requestStr && [requestStr length] > 0)
    {
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        
        NSEnumerator *er = [[requestStr componentsSeparatedByString:@"&"] objectEnumerator];
        
        id anObject;
        
        while (anObject = [er nextObject]) {
            
            NSArray *arr = [(NSString *)anObject componentsSeparatedByString:@"="];
            
            if ([arr count] != 2)
            {
                continue;
            }
            
            [params setObject:[arr objectAtIndex:1] forKey:[arr objectAtIndex:0]];
        }
        
        TopIOSClient *iosClient = [TopAppDelegate getInnerClient];
        [iosClient api:false method:@"POST" params:params target:self cb:@selector(showApiResponse:)];
        
    }
    else {
        
        [self message:@"必须填入请求地址."];    
    }
    
}

-(void) message:(NSString *)content
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Infomation"
                                                      message:content
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}
 
-(void)showApiResponse:(id)data
{
    if ([data isKindOfClass:[NSString class]])
    {
        NSLog(@"%@",data);
        [responseContentView setText:data];
    }
    else {
        NSLog(@"%@",[(NSError *)data userInfo]);
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [self setReqTextField:nil];
    [self setReqButton:nil];
    [self setResponseContentView:nil];
    [self setAuthButton:nil];
    
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
