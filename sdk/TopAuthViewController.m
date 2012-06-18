//
//  TopAuthViewController.m
//  sdk
//
//  Created by cenwenchu on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopAuthViewController.h"

@implementation TopAuthViewController

@synthesize authWebView;
@synthesize command;


+ (void)cleanForDeallocWebView:(UIWebView *)webView
{
    [webView loadHTMLString:@"" baseURL:nil];
    [webView stopLoading];
    [webView setDelegate:nil];
    [webView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([command isEqualToString:@"auth"])
    {
        TopIOSClient *iosClient = [TopAppDelegate getInnerClient];
        [iosClient auth:authWebView];
    }
}

- (void)viewDidUnload
{
    [self setAuthWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *url = [[[webView request] URL] absoluteString];
    
    NSArray *listItems = [url componentsSeparatedByString:@"#"];
    
    NSEnumerator *enumerator = [listItems objectEnumerator];
    id anObject;
    
    while (anObject = [enumerator nextObject]) {
        
        NSRange range = [(NSString *)anObject rangeOfString:@"access_token="];
        
        if (range.location == NSNotFound)
            continue;
        else {
            NSRange end = [(NSString *)anObject rangeOfString:@"&"];
            NSString *access_token;
            
            if (end.location == NSNotFound)
            {
                access_token = [(NSString *)anObject substringFromIndex:range.location+range.length];
            }
            else {
                access_token = [(NSString *)anObject substringWithRange:NSMakeRange(range.location+range.length,end.location - range.location - range.length)];
            }
            
            
            NSLog(@"%@",access_token);
            NSLog(@"%@",(NSString *)anObject);
            
            TopIOSClient *iosClient = [TopAppDelegate getInnerClient];
            
            [iosClient setAccessToken:access_token];
            
            [self.navigationController popViewControllerAnimated:TRUE];
            
            break;
        }
    }
    
}

@end
