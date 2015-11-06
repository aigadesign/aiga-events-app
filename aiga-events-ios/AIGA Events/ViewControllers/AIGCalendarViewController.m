//
//  AIGCalendarViewController.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/6/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGCalendarViewController.h"
#import "AIGAppDelegate.h"
#import "CalendarControl.h"
#import "AIGCoreDataManager.h"
#import "AIGEventDetailViewController.h"
#import "AIGChapter+Extensions.h"
#import "AIGEventCell.h"
#import "AIGEventCell+Geometry.h"
#import "AIGActivityIndicator.h"
#import "AIGNotifierView.h"
#import "AFNetworkReachabilityManager.h"
#import "AIGEventDataDownloadManager.h"
#import "NSDate+Extensions.h"


@interface AIGCalendarViewController () <CalendarControlDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate>

@property (nonatomic, weak) IBOutlet CalendarControl *calendarControl;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *selectedDatesEvents;

@property (nonatomic, strong) NSLayoutConstraint *calendarHeightConstraint;

@property (nonatomic, strong) AIGActivityIndicator *activityIndicator;

@property (nonatomic, assign) BOOL isCurrentlySelected;
@property (nonatomic, strong) AIGEventCell *sizingCell;

@property (nonatomic, assign) BOOL isFirstTimeViewing;
@end

@implementation AIGCalendarViewController

static NSString *CellIdentifier = @"EventCell";
static NSString *DetailViewSegue = @"DetailViewSegue";

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
    
    self.isFirstTimeViewing = YES;
    
    // Refresh button
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(reloadEventData)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    
    self.title = NSLocalizedString(@"CALENDAR", nil);
    
    self.tableView.dataSource = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"AIGEventCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CellIdentifier];
    
    self.tableView.separatorColor = [UIColor whiteColor];

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.calendarControl
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:300];
    [self.view addConstraint:constraint];
    self.calendarHeightConstraint = constraint;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    self.activityIndicator = [[AIGActivityIndicator alloc] initWithFrame:self.view.frame];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.delegate = self;
    
    //only show refresh button if a chapter is selected
    NSArray *chapters = [AIGChapter selectedChapters];
    if (chapters.count > 0) {
        // Refresh button
        UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(reloadEventData)];
        self.navigationItem.rightBarButtonItem = refreshBtn;
        
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }

    self.calendarControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.calendarControl.delegate = self;

    [self refreshCalendar];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.tabBarController.delegate = nil;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.calendarHeightConstraint.constant = self.calendarControl.intrinsicContentSize.height;
    [self.view setNeedsLayout];
    
    self.isCurrentlySelected = YES;
    
    if (self.isFirstTimeViewing) {
        [self.calendarControl selectDate:[NSDate date]];
        self.isFirstTimeViewing = NO;
    }
    else
    {
        [self.calendarControl selectDate:self.calendarControl.selectedDate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Refresh list

- (void)applicationWillForeground:(NSNotification *)notification
{
    [self reloadEventDataWithRefreshCompletionHandler:nil];
}

- (void)reloadEventData
{
    NSInteger networkStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (networkStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [AIGNotifierView showNotifierWithMessage:NETWORKUNAVALAIBLEWARNING];
        return;
    }

    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator show];
    [self reloadEventDataWithRefreshCompletionHandler:nil];
}

- (void)reloadEventDataWithRefreshCompletionHandler:(void (^)(UIBackgroundFetchResult))refreshCompletionHandler
{
    AIGAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate reloadEventDataWithRefreshCompletionHandler:^(UIBackgroundFetchResult refreshCompletionHandler) {
        [self.activityIndicator hide];
        
        [self refreshCalendar];
    }];
}

- (void)refreshCalendar
{
    NSMutableArray *events = [NSMutableArray array];
    for (AIGChapter *chapter in [AIGChapter selectedChapters]) {
        NSArray *chapterEvents = [chapter eventsForChapter];
        [events addObjectsFromArray:chapterEvents];
    }
    
    self.events = events;
    self.calendarControl.aigEvents = events;
    
    [self.calendarControl setNeedsDisplay];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([AIGChapter selectedChapters].count == 0 ||
        self.selectedDatesEvents == nil) {
        return 0;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MAX(self.selectedDatesEvents.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIGEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.isInCalendarList = YES;
    
    AIGEvent *event = nil;
    if (self.selectedDatesEvents.count > indexPath.row) {
        event = self.selectedDatesEvents[indexPath.row];
    }
    
    [cell populateFromEvent:event];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    if ([UIViewController instancesRespondToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
        // iOS 8+
        height = UITableViewAutomaticDimension;

    } else {
        AIGEvent *event = nil;
        if (self.selectedDatesEvents.count > indexPath.row) {
            event = self.selectedDatesEvents[indexPath.row];
        }
        
        height = [AIGEventCell aig_heightForCellWithEvent:event isInCalendar:YES];
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIGEvent *event;
    if (self.selectedDatesEvents.count > indexPath.row) {
        event = self.selectedDatesEvents[indexPath.row];
    }
    
    [self performSegueWithIdentifier:DetailViewSegue sender:event];
}


#pragma mark - CalendarControlDelegate

- (void)calendarControl:(CalendarControl *)calendarControl didSelectDate:(NSDate *)selectedDate
{
    NSMutableArray *array = [NSMutableArray array];
    for (AIGEvent *event in self.events) {
        
        if ([NSDate date:selectedDate isBetweenDate:event.startTime andDate:event.endTime])
        {
            [array addObject:event];
        }
        else if ([event.startTime aig_IsSameDay:selectedDate]) {
            [array addObject:event];
        }
    }
    
    self.selectedDatesEvents = [array copy];
    [self.tableView reloadData];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
    self.tableView.scrollEnabled = array.count > 0;
}

- (void)monthChangedInCalendarControl:(CalendarControl *)calendarControl
{
    self.calendarHeightConstraint.constant = self.calendarControl.intrinsicContentSize.height;
    [self.view setNeedsLayout];
    self.selectedDatesEvents = nil;
    [self.tableView reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:DetailViewSegue]) {
        AIGEventDetailViewController *eventDetailVC = segue.destinationViewController;
        eventDetailVC.currentEvent = sender;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    }
}

#pragma mark - UITabBarControllerDelegate

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController == self.navigationController) {
        if (self.isCurrentlySelected) {
            [self.calendarControl showCurrentMonth];
        }
    }
    else {
        self.isCurrentlySelected = NO;
    }
}

@end
