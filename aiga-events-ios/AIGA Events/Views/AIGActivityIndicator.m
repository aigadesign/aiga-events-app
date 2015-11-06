//
//  AIGActivityIndicator.m
//  AIGA Events
//
//  Created by Tony Bentley on 11/22/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGActivityIndicator.h"



@interface AIGActivityIndicator ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end




@implementation AIGActivityIndicator


//INIT WITH VIEW's FRAME
//AIGActivityIndicator *indicator = [[AIGActivityIndicator alloc]initWithFrame:self.view.frame];

//[self.view addSubview:indicator];
//[indicator show];
//[indicator hide];

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.alpha = 0;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        [self.activityIndicator.layer setBackgroundColor:[[UIColor colorWithWhite: 0.0 alpha:0.30] CGColor]];
        CGPoint center = self.center;
        self.activityIndicator.center = center;
        
        self.activityIndicator.frame = self.bounds;
        
        [self addSubview:self.activityIndicator];
        
        
    }
    
    return self;
}

- (void) hide
{
    [self.activityIndicator stopAnimating];
    [self removeFromSuperview];
}


- (void) show
{
    self.alpha = 1;
    [self.activityIndicator startAnimating];
    
}


@end
