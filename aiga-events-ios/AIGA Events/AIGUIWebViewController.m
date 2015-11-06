//
//  AIGUIWebViewController.m
//  AIGA Events
//
//  Created by Tony Bentley on 11/19/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGUIWebViewController.h"

@interface AIGUIWebViewController ()


@end

@implementation AIGUIWebViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSURL *mainBundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSString *htmlString = [[NSString alloc] initWithData:
                            [readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
  
   
    NSString *tempString = [htmlString stringByReplacingOccurrencesOfString:@"{{body}}" withString:_HTMLString];
    
    
    [self.webView loadHTMLString:tempString baseURL:mainBundleURL];

	//[[self webView] loadHTMLString:_HTMLString baseURL:mainBundleURL];
}

- (void) setHTMLString:(NSString *)HTMLString
{
    //NSLog(@"%s",__PRETTY_FUNCTION__);
    _HTMLString = HTMLString;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
     NSLog(@"Request!");
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"Completed!");
    
}

@end
