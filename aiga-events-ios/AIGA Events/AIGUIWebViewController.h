//
//  AIGUIWebViewController.h
//  AIGA Events
//
//  Created by Tony Bentley on 11/19/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIGUIWebViewController : UIViewController <UIWebViewDelegate>


@property (copy, nonatomic)  NSString *HTMLString;
@property (weak,nonatomic) IBOutlet UIWebView *webView;


@end
