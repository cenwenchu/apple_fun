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
@synthesize uploadPicButton;
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
    //TopIOSClient *iosClient = [TopIOSClient getIOSClientByAppKey:@"470437"];
    [iosClient auth:self cb:@selector(authCallback:)];
}

- (IBAction)tqlRequest:(id)sender {
    TopIOSClient *iosClient = [TopIOSClient getIOSClientByAppKey:@"12131533"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *uid = [userId text];
    
    [params setValue:@"select num_iid,title,type,location from item where num_iid=17795332215" forKey:@"ql"];
    
    [iosClient tql:@"GET" params:params target:self cb:@selector(showApiResponse:) userId:uid];
}

- (IBAction)uploadPicAction:(id)sender {
    
    NSString *uid = [userId text];
    //NSString *uid = @"2026680875";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    
    [params setObject:@"taobao.item.img.upload" forKey:@"method"];
    [params setObject:@"17795332215" forKey:@"num_iid"];
    
   
    NSURL *url = [[NSURL alloc] initWithString:@"http://img01.taobaocdn.com/bao/uploaded/i1/T1X4TeXb0jXXX39Ro3_051047.jpg_310x310.jpg"];
    NSData *image_data = [NSData dataWithContentsOfURL:url];
    
    Attachment *image = [[Attachment alloc]init];
    [image setData:image_data];
    [image setName:@"mypic.jpg"];
    
    
    [params setObject:image forKey:@"image"];
    //[params setObject:@"6101f2833fb2742ac2557f49ee6a23a4b4811641cb50b802026680875" forKey:@"session"];
    
    TopIOSClient *iosClient =[TopIOSClient getIOSClientByAppKey:@"12131533"];
    //TopIOSClient *iosClient = [TopIOSClient getIOSClientByAppKey:@"470437"];
    
    
    [iosClient api:@"POST" params:params target:self cb:@selector(showApiResponse:) userId:uid];
    
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
        [iosClient api:@"POST" params:params target:self cb:@selector(showApiResponse:) userId:uid];
        
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
    [self setUploadPicButton:nil];
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
