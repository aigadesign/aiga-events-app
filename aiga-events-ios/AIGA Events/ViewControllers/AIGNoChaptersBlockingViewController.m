//
//  AIGNoChaptersBlockingViewController.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/12/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGNoChaptersBlockingViewController.h"
#import "AIGCoreDataManager.h"
#import "UIColor+Extensions.h"
#import "UIFont+AIGAExtensions.h"
#import "AIGActivityIndicator.h"
#import "AIGChapter+Extensions.h"

@interface AIGNoChaptersBlockingViewController ()

@property (nonatomic, strong) UIView *blockingView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation AIGNoChaptersBlockingViewController

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
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"Interstate-Light" size:18];
    self.titleLabel.textColor = [UIColor aig_DarkBlackColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel sizeToFit];
    self.navigationItem.titleView = self.titleLabel;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.title;
    [self.titleLabel sizeToFit];
    
    NSArray *chapters = [AIGChapter selectedChapters];

    if (chapters.count == 0) {
        if (self.blockingView == nil) {
            UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
            view.userInteractionEnabled = NO;
            view.backgroundColor = [UIColor whiteColor];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 100.0, 240.0, 300.0)];
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 0;
            label.font = [UIFont fontWithName:@"Interstate-Regular" size:16];
            label.text = @"To display events, please select one or more AIGA chapters on the Chapters tab.";
            label.textColor = [UIColor aig_MediumLightGrayColor];
            [view addSubview:label];
            
            [self.view addSubview:view];
            self.blockingView = view;
            
            self.view.userInteractionEnabled = NO;
        }
    } else {
        if (self.blockingView != nil) {
            [self.blockingView removeFromSuperview];
            self.blockingView = nil;

            self.view.userInteractionEnabled = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end