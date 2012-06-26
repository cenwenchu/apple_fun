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
@synthesize tqlButton;
@synthesize responseContentView;
@synthesize userId;
@synthesize userIds;



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.reqTextField) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (IBAction)authAction:(id)sender {
    TopIOSClient *iosClient = [TopIOSClient getIOSClientByAppKey:@"12131533"];
    [iosClient auth:self cb:@selector(authCallback:)];
}

- (IBAction)tqlRequest:(id)sender {
    TopIOSClient *iosClient = [TopIOSClient getIOSClientByAppKey:@"12131533"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *uid = [userId text];
    
    [params setValue:@"select uid,nick,sex,location from user where nick=cenwenchu" forKey:@"ql"];
    
    [iosClient tql:@"GET" params:params target:self cb:@selector(showApiResponse:) userId:uid];
}

- (IBAction)sendRequestAction:(id)sender {
   
    [responseContentView setText:nil];
    
    NSString *requestStr = reqTextField.text;
    NSString *uid = [userId text];
    
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
        
        TopIOSClient *iosClient =[TopIOSClient getIOSClientByAppKey:@"12131533"];
        [iosClient api:@"GET" params:params target:self cb:@selector(showApiResponse:) userId:uid];
        
    }
    else {
        
        [self message:@"必须填入请求地址."];    
    }
    
}

-(void) authCallback:(id)data
{
    
    TopAuth *auth = (TopAuth *)data;
    
    [userIds addObject:[auth user_id]];
    
    NSLog(@"%@",[auth user_id]);
    
    [userId setText:[auth user_id]];
    
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
    
    userIds = [[NSMutableArray alloc]init];
}

- (void)viewDidUnload
{
    [self setReqTextField:nil];
    [self setReqButton:nil];
    [self setResponseContentView:nil];
    [self setAuthButton:nil];
    
    [self setTqlButton:nil];
    [self setUserId:nil];
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
