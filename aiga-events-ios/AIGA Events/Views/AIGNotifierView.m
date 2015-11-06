//
//  AIGNotifierView.m
//  AIGA Events
//
//  Created by Dennis Birch on 12/6/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGNotifierView.h"
#import "UIFont+AIGAExtensions.h"

@implementation AIGNotifierView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (void)showNotifierWithMessage:(NSString *)message
{
    UIView *parentView = [[UIApplication sharedApplication].windows firstObject];
    
    CGRect parentFrame = parentView.frame;
    parentFrame.size.height = 60.0;
    AIGNotifierView *newView = [[AIGNotifierView alloc]initWithFrame:parentFrame];
    
    newView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 3.5f;
   	
	NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle};
    
    // add label with message
    CGRect labelFrame = CGRectInset(parentFrame, 8.0, 8.0);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.font = [UIFont aig_DetailsLabelFont];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.attributedText = [[NSAttributedString alloc] initWithString:message attributes:attributes];
    [newView addSubview:label];
    
    
    // display from top of parent view
    // start by resetting frame to start above view's top
    parentFrame.origin.y = parentFrame.size.height * -1.0;
    newView.frame = parentFrame;
    [parentView addSubview:newView];
    [UIView animateWithDuration:.25 animations:^{
        CGAffineTransform tranform = CGAffineTransformMakeTranslation(0, parentFrame.size.height);
        newView.transform = tranform;
        
    } completion:^(BOOL finished) {
        // remove
        double delayInSeconds = 4.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:.35 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeTranslation(0, parentFrame.size.height * -1);
                newView.transform = transform;
            } completion:^(BOOL finished) {
                [newView removeFromSuperview];
            }];
        });
    }];
}


@end
