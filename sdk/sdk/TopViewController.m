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
@synthesize messageAlertLabel;



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.reqTextField) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"authPush"]) {
        
        //UIWindow *win = [[self view] window];
         
        //这个过程里面对方controller都还没有创建view
        TopAuthViewController *authViewController = [segue destinationViewController];
        [authViewController setCommand:@"auth"];
        
//        UIWebView *authview = [authViewController authWebView];
//        
//        if(authview == Nil)
//        {
//            UIWebView *webView = [[UIWebView alloc] initWithFrame:[[authViewController view] bounds]]; 
//            [webView setBackgroundColor:[UIColor redColor]];
//            webView.scalesPageToFit = YES;
//            
//            [authViewController setAuthWebView:webView];
//            [webView setDelegate:authViewController];
//            
//        }
//        
//        [win addSubview:[authViewController authWebView]];
//        [win makeKeyAndVisible];
        
    }
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
        [iosClient api:@"rest" method:@"POST" params:params target:self cb:@selector(showApiResponse:)];
        
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
 
-(void)showApiResponse:(NSData *)data
{
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [responseContentView setText:[NSString stringWithUTF8String:[data bytes]]];
}

-(void)messageNotify:(NSNotification *)paramNotification
{
    NSLog(@"message received");
    NSDictionary *userInfo = [paramNotification userInfo];
    
    id error = [userInfo objectForKey:@"error"];
    
    if (error)
    {
        NSMutableString *errMsg = [[NSMutableString alloc]init];
        [errMsg appendString:@"error code : "];
        [errMsg appendFormat:@"%d",[(NSError *)error code]];
        [messageAlertLabel setText:errMsg];
    }
    {
        [messageAlertLabel setText:@"a new message"];
        [messageAlertLabel setTextColor:[UIColor colorWithRed:0.5f
                                                        green:0.0f blue:0.5f alpha:1.0f]];
        
        [self message:@"you got response from api server"];    
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageNotify:) name:MessageArriveNotification  object:self];    
}

- (void)viewDidUnload
{
    [self setReqTextField:nil];
    [self setReqButton:nil];
    [self setResponseContentView:nil];
    [self setAuthButton:nil];
    [self setMessageAlertLabel:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
