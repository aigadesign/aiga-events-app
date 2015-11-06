//
//  AIGEventListViewController.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventListViewController.h"
#import "AIGEventDetailViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "AIGEventCell.h"
#import "AIGEvent+Extensions.h"
#import "AIGChapter+Extensions.h"
#import "AIGEventCell+Geometry.h"
#import "AIGCoreDataManager.h"
#import "AIGEventHeaderView.h"
#import "AIGActivityIndicator.h"
#import "AIGEventDataDownloadManager.h"
#import "AIGNotifierView.h"
#import "UIColor+Extensions.h"
@import EventKit;

@interface AIGEventListViewController () <UITableViewDataSource, UITableViewDelegate,
    UIScrollViewDelegate, AIGEventHeaderDelegate, UITabBarControllerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *chapters;
@property (nonatomic, strong) AIGChapter *mainChapter;
@property (nonatomic, strong) AIGChapter *firstChapter;
@property (nonatomic, strong) AIGChapter *lastChapter;

@property (nonatomic, strong) NSArray *mainEventsArray;
@property (nonatomic, strong) NSArray *firstEventsArray;
@property (nonatomic, strong) NSArray *lastEventsArray;

@property (nonatomic, strong) UITableView *firstTableView;
@property (nonatomic, strong) UITableView *lastTableView;
@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, assign) NSInteger currentChapterNum;
@property (nonatomic, assign) NSUInteger lastChapterNum;
@property (nonatomic, assign) CGFloat lastScrollX;
@property (nonatomic, assign) CGFloat mainTableHeight;

@property (nonatomic, assign) BOOL scrollInitiatedByHeaderButton;
@property (nonatomic, assign) BOOL isCurrentlySelected;

@property (nonatomic, strong) NSLayoutConstraint *scrollViewHeightConstraint;

@property (nonatomic, strong) AIGActivityIndicator *activityIndicator;
@property (nonatomic, assign) BOOL justShowedEventDetails;

@property (nonatomic, strong) AIGEventCell *sizingCell;

@end

@implementation AIGEventListViewController

typedef NS_ENUM(NSInteger, ScrollDirection) {
    ScrollDirectionLeft = -1,
	ScrollDirectionNone = 0,
    ScrollDirectionRight = 1,
};


static NSString *CellIdentifier = @"EventCell";
static NSString *LastViewedChapter = @"LastViewedPage";
static NSString *EventDetailSegue = @"EventDetailSegue";
static NSString *DisplayCalendarSegue = @"DisplayCalendarSegue";

#pragma mark - Life Cycle Methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"EVENTS", nil);
    self.chapters = [AIGChapter sortedChapters];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResign:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedChapters)
                                                 name:ChapterSelectionsChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloadCompleted:)
                                                 name:ImageDownloadCompletionNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideActivityIndicatorIfNotLoading)
                                                 name:EventsDoneDownloadingNotification
                                               object:nil];

    self.scrollView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.firstTableView = [self chapterEventsTableView];
    [self.scrollView addSubview:self.firstTableView];
    
    self.mainTableView = [self chapterEventsTableView];
    self.mainTableView.delaysContentTouches = NO;
    [self.scrollView addSubview:self.mainTableView];
    
    self.lastTableView = [self chapterEventsTableView];
    [self.scrollView addSubview:self.lastTableView];

    self.justShowedEventDetails = NO;
    
    // set up for constraints
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.firstTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lastTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupViewConstraints];
    
    [self loadChapters];

    self.lastChapterNum = -1;
    
    self.activityIndicator = [[AIGActivityIndicator alloc] initWithFrame:self.view.frame];
    
    [self showRefreshButton];
}


- (void)showRefreshButton
{
    // Refresh button
    if ([self.chapters count] > 0) {
        UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(reloadEventData)];
        
        self.navigationItem.rightBarButtonItem = refreshBtn;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


- (void)setupViewConstraints
{
    // arrange tableviews horizontally in scrollview
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_firstTableView, _mainTableView, _lastTableView);

    CGFloat width = self.scrollView.bounds.size.width;
    NSString *format = [NSString stringWithFormat:@"H:|[_firstTableView(%f)][_mainTableView(%f)][_lastTableView(%f)]|", width, width, width];
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDict];
    [self.scrollView addConstraints:constraints];
    
    // theoretically we should be able to pin the tableViews to the top and bottom of the scrollview, but that doesn't work in practice
    // so instead we'll pin their tops and constrain the height for each tableView to the scrollView's height.

    // set vertical constraints for tableviews within scrollview
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.mainTableView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.scrollView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1
                                                                   constant:0];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.mainTableView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.scrollView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1
                                               constant:0];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.firstTableView
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.scrollView
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1
                                               constant:0];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.firstTableView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.scrollView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1
                                               constant:0];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.lastTableView
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.scrollView
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1
                                               constant:0];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.lastTableView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.scrollView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1
                                               constant:0];
    [self.scrollView addConstraint:constraint];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.delegate = self;

    if ([[AIGEventDataDownloadManager sharedEventDataDownloadManager] isLoadingChapterEvents])
    {
        [self.view addSubview:self.activityIndicator];
        [self.activityIndicator show];
    }

    [self.mainTableView deselectRowAtIndexPath:[self.mainTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:HASDISPLAYEDINITIALCHAPTERSLIST]) {
        self.tabBarController.selectedIndex = 2;
        
        self.navigationItem.backBarButtonItem.title = nil;

    } else {
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (error != nil) {
                NSLog(@"Error initializing AddressBook access: %@", [error localizedDescription]);
            }
        }];
    }

    [defaults setBool:YES forKey:HASDISPLAYEDINITIALCHAPTERSLIST];
    [defaults synchronize];
    self.isCurrentlySelected = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.tabBarController.delegate = nil;

}

-(void)showFirstChapter
{
    self.currentChapterNum = 0;
    self.scrollView.contentOffset = CGPointZero;

    [self updateChaptersAndTables];
    
    self.scrollInitiatedByHeaderButton = NO;
}

- (UITableView *)chapterEventsTableView
{
	UITableView *tableView = [[UITableView alloc] init]; //]WithFrame:frame];
    [tableView registerNib:[UINib nibWithNibName:@"AIGEventCell"
                                          bundle:[NSBundle mainBundle]]
    forCellReuseIdentifier:CellIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.userInteractionEnabled = YES;
    tableView.allowsSelection = YES;

    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor whiteColor];
    
    // minimum cell height
    tableView.rowHeight = 120;
	
	return tableView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // regenerate images as needed on re-display
    for (AIGChapter *chapter in self.chapters) {
        if (chapter != self.mainChapter) {
            for (AIGEvent *event in chapter.events) {
                event.thumbnailImage = nil;
            }
        }
    }
}

#pragma mark - Notification Handling

- (void)applicationWillResign:(NSNotification *)note
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.mainChapter.city forKey:LastViewedChapter];
    [defaults synchronize];
}


- (void)applicationWillForeground:(NSNotification *)notification
{
    [self reloadEventDataWithRefreshCompletionHandler:nil];
}

#pragma mark - Data Loading

- (void)loadMainTable
{
    [self.mainTableView reloadData];
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
    // reloads the data for the main table view
    AIGChapter *chapter = self.mainChapter;

    if (chapter == nil) {
        return;
    }
    
    [[AIGEventDataDownloadManager sharedEventDataDownloadManager]
     downloadEventbriteEventsForChapter:chapter
     completionHandler:^(NSDictionary *responseDict, NSError *error) {
         if (responseDict == nil) {
             // we've already logged the error so no need to here
             [self.activityIndicator hide];
             if (refreshCompletionHandler != nil) {
                 refreshCompletionHandler(UIBackgroundFetchResultFailed);
             }
         } else {
             [AIGEvent importEventbriteEvents:responseDict
                                   forChapter:chapter
                                  dataManager:[AIGCoreDataManager sharedCoreDataManager]
                            completionHandler:^(BOOL hasChanges) {
                 if (hasChanges) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self loadMainTable];
                         if (refreshCompletionHandler != nil) {
                             refreshCompletionHandler(UIBackgroundFetchResultNewData);
                         }
                     });
                 } else {
                     if (refreshCompletionHandler != nil) {
                         refreshCompletionHandler(UIBackgroundFetchResultNoData);
                     }
                     [self.activityIndicator hide];
                 }
             }];
         }
     }];
    
    
    // get data from ETouches
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [NSDate distantFuture];
    [[AIGEventDataDownloadManager sharedEventDataDownloadManager]
     downloadETouchesEventsForChapter:chapter
     startDate:startDate
     endDate:endDate
     completionHandler:^(NSArray *responseArray, NSError *error) {
         if (responseArray == nil) {
             [self.activityIndicator hide];
             if (refreshCompletionHandler != nil) {
                 refreshCompletionHandler(UIBackgroundFetchResultFailed);
             }
         } else {
             [AIGEvent importETouchesEvents:responseArray forChapter:chapter completionHandler:^(BOOL hasChanges) {
                 if (hasChanges) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self loadMainTable];
                         if (refreshCompletionHandler != nil) {
                             refreshCompletionHandler(UIBackgroundFetchResultNewData);
                         }
                         [self.activityIndicator hide];
                     });
                 }
             }];
         }
         
     }];
}


- (void)loadChapters
{
    // check to see if the current view needs to change
    if ([self.chapters indexOfObject:self.mainChapter] != NSNotFound) {
        return;
    }
    
    NSString *currentChapter = [[NSUserDefaults standardUserDefaults] objectForKey:LastViewedChapter];
    NSInteger first = 0;
    // get the index for the last viewed chapter
    for (int i = 0; i < self.chapters.count; i++) {
        AIGChapter *chapter = self.chapters[i];
        if ([chapter.city isEqualToString:currentChapter]) {
            first = i;
            break;
        }
    }
    
    for (NSInteger i = first - 1; i <= first + 2; i++) {
        if (self.chapters.count > i) {
            AIGChapter *chapter = self.chapters[i];
            if (i == first && chapter != nil) {
                self.mainChapter = chapter;
                self.mainEventsArray = [chapter eventsForChapter];
            } else if (i == first + 1 && chapter != nil) {
                self.lastChapter = chapter;
            } else if (i == (first + 2) && chapter != nil) {
                self.firstChapter = chapter;
                self.firstEventsArray = [chapter eventsForChapter];
            }
        }
    }
    
    // user's last selected chapter is now the main chapter, but check to see if we loaded as many as possible
    if ((self.lastChapter == nil || self.firstChapter == nil) && self.chapters.count > 1) {
        for (int i = 0; i < self.chapters.count; i++) {
            if (self.chapters.count > i) {
                AIGChapter *chapter = self.chapters[i];
                
                if (chapter != nil && self.lastChapter == nil && chapter != self.mainChapter && chapter != self.firstChapter && chapter != self.lastChapter) {
                    self.lastChapter = chapter;
                    self.lastEventsArray = [chapter eventsForChapter];
                    
                } else if (chapter != nil && self.firstChapter == nil && chapter != self.mainChapter && chapter != self.firstChapter && chapter != self.lastChapter) {
                    self.firstChapter = chapter;
                    self.firstEventsArray = [chapter eventsForChapter];
                }
                
            }
        }
        
    }
    
    self.currentChapterNum = first;
    self.lastChapterNum = first;
    [self updateChaptersAndTables];
}


#pragma mark - Table view data source

- (AIGChapter *)chapterForTableView:(UITableView *)tableView
{
    AIGChapter *chapter;
    if (tableView == self.mainTableView) {
        chapter = self.mainChapter;
    } else if (tableView == self.firstTableView) {
        chapter = self.firstChapter;
    } else if (tableView == self.lastTableView) {
        chapter = self.lastChapter;
    }

    return chapter;
}

- (NSArray *)dataArrayForTableView:(UITableView *)tableView
{
    NSArray *array;
    if (tableView == self.mainTableView) {
        array = self.mainEventsArray;
    } else if (tableView == self.firstTableView) {
        array = self.firstEventsArray;
    } else if (tableView == self.lastTableView) {
        array = self.lastEventsArray;
    }
    
    return array;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.chapters.count == 0) {
        return 0;
    }
    if ([[AIGEventDataDownloadManager sharedEventDataDownloadManager] isLoadingChapterEvents])
    {
        return 0;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AIGChapter *chapter = [self chapterForTableView:tableView];
    AIGChapter *prevChapter;
    AIGChapter *nextChapter;

    if (tableView==self.mainTableView) {
        prevChapter = [self chapterForTableView:self.firstTableView];
        nextChapter = [self chapterForTableView:self.lastTableView];
    }
    else if (tableView==self.firstTableView) {
        prevChapter = nil;
        nextChapter = [self chapterForTableView:self.mainTableView];
    }
    else  { //assume (tableView==self.lastTableView)
        prevChapter = [self chapterForTableView:self.mainTableView];
        nextChapter = nil;
    }

    CGRect hFrame = CGRectMake(0, 0, self.view.bounds.size.width, 35);
    AIGEventHeaderView *headerView = [[AIGEventHeaderView alloc] initWithFrame:hFrame];
    [headerView setChapterName:chapter.city];
    headerView.delegate = self;
    
    if (tableView == self.mainTableView) {
        [headerView setChapter:chapter previousChapter:prevChapter nextChapter:nextChapter];
    }

    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [self dataArrayForTableView:tableView];
    
    // return at least "1" so that we can show a "No events" cell
    return MAX(1, array.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AIGEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSArray *chapterEvents = [self dataArrayForTableView:tableView];

    AIGEvent *event = nil;
    if (chapterEvents.count > indexPath.row) {
        event = chapterEvents[indexPath.row];
    }

    [cell populateFromEvent:event];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 144;
    
    if (![UIViewController instancesRespondToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
        // iOS 7
        NSArray *chapterEvents = [self dataArrayForTableView:tableView];
        
        AIGEvent *event = nil;
        if (chapterEvents.count > indexPath.row) {
            event = chapterEvents[indexPath.row];
        }
        
        if (event == nil) {
            height = 100;
        }
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    if ([UIViewController instancesRespondToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
        // iOS 8+
        height = UITableViewAutomaticDimension;

    } else {
        NSArray *chapterEvents = [self dataArrayForTableView:tableView];

        AIGEvent *event = nil;
        if (chapterEvents.count > indexPath.row) {
            event = chapterEvents[indexPath.row];
        }
        
        height = [AIGEventCell aig_heightForCellWithEvent:event isInCalendar:NO];
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:EventDetailSegue sender:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:EventDetailSegue]) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];

        NSIndexPath *indexPath = [self.mainTableView indexPathForSelectedRow];
        AIGEventCell *cell = (AIGEventCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
        AIGEventDetailViewController *detailVC = segue.destinationViewController;
        detailVC.currentEvent = cell.event;
        self.justShowedEventDetails = YES;
    }
}


#pragma mark - Chapter Selection Notifications

- (void)selectedChapters
{
    self.chapters = [AIGChapter sortedChapters];
    
    if (self.chapters.count == 0) {
        self.mainChapter = nil;
    } else {
        if ([self.chapters indexOfObject:self.mainChapter] == NSNotFound) {
            [self loadChapters];
        }
    }
    
    [self loadMainTable];
    
    [self showRefreshButton];
    [self hideActivityIndicatorIfNotLoading];
}

- (void)hideActivityIndicatorIfNotLoading
{
    if (![[AIGEventDataDownloadManager sharedEventDataDownloadManager] isLoadingChapterEvents])
    {
        [self loadMainTable];    //in case we need to now display the "no events" cell
        [self.activityIndicator hide];
    }
}

#pragma mark - ImageDownloadCompletionNotification

- (void)imageDownloadCompleted:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *eventBritesID = userInfo[@"eventBritesID"];
    NSNumber *eTouchesID = userInfo[@"eTouchesID"];
    UIImage *placeholder = [AIGEventCell placeholderThumbnail];
    // see if there's a new thumbnail and we need to refresh

    // see if any visible cells are showing placeholder
    NSArray *cells = self.mainTableView.visibleCells;
    BOOL hasPlaceholderImage = NO;
    
    for (AIGEventCell *cell in cells) {
        if (cell.thumbnailImageView.image == placeholder) {
            hasPlaceholderImage = YES;
            break;
        }
    }
    
    if (!hasPlaceholderImage) {
        return;
    }
    
    for (AIGEvent *event in self.mainChapter.events) {
        if ( (eventBritesID != nil && [event.eventBriteID isEqualToNumber:eventBritesID])
                || (eTouchesID != nil && [event.eTouchesID isEqualToNumber:eTouchesID]) ) {
            [self loadMainTable];
            break;
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
     if (scrollView == self.scrollView) {
         
        NSInteger width = scrollView.bounds.size.width;
        
        BOOL dontScrollLeft = NO;
        BOOL dontScrollRight = NO;
        
        CGPoint offset = scrollView.contentOffset;
        NSInteger scrollX = NSNotFound;
        
        ScrollDirection direction;
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
         
        if (translation.x > 0) {
            direction = ScrollDirectionLeft;
        } else if (translation.x < 0) {
            direction = ScrollDirectionRight;
        } else {
            return;
        }
        
        if (self.scrollInitiatedByHeaderButton) {
            return;
        }
        
        // restrict scrolling beyond limitations
        if (self.currentChapterNum <= 0  && direction == ScrollDirectionLeft) {
            // don't allow scrolling to the left
            dontScrollLeft = YES;
        } else if (self.currentChapterNum >= self.chapters.count - 1 && direction == ScrollDirectionRight) {
            // don't allow scrolling to the right
            dontScrollRight = YES;
        }
        
        if (self.chapters.count == 1) {
            scrollX = width;
            
        } else if (dontScrollLeft) {
            if (direction == ScrollDirectionLeft) {
                scrollX = width;
            } else {
                scrollX = scrollView.contentOffset.x;
            }
            
        } else if (dontScrollRight && direction == ScrollDirectionRight) {
            self.scrollView.contentOffset = CGPointMake(width, 0);
            return;
        }
        
        // scroll header and main section together
        if (scrollX != NSNotFound) {
            // we hit this when attempting to scroll left beyond first chapter
            offset.x = scrollX;
            self.scrollView.contentOffset = offset;
            self.scrollView.contentOffset = offset;
        } else {
            self.scrollView.contentOffset = offset;
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    // ignore if it's a tableview
    if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }

    NSInteger direction;
    
    if (scrollView.contentOffset.x < self.lastScrollX) {
        direction = ScrollDirectionLeft;
    } else if (scrollView.contentOffset.x > self.lastScrollX) {
        direction = ScrollDirectionRight;
    } else {
        direction = ScrollDirectionNone;
    }
    
    if (direction == ScrollDirectionNone) {
        self.lastScrollX = scrollView.contentOffset.x;
        return;
    }
    else if (direction == ScrollDirectionLeft) {
        if (self.currentChapterNum > 0) {
            self.currentChapterNum--;
        }
    } else if (direction == ScrollDirectionRight) {
        if (self.currentChapterNum < self.chapters.count - 1) {
            self.currentChapterNum++;
        }
    }

    [self updateChaptersAndTables];

    self.lastScrollX = scrollView.contentOffset.x;
}

- (void)updateChaptersAndTables
{
    // Align chapters so that the main chapter is in the middle,
    // the previous chapter is to the left (firstTable), and the  next chapter is to the right (lastTableView)
    
    if (self.chapters.count < self.currentChapterNum + 1) {
        return;
    }
    
    self.lastChapterNum = self.currentChapterNum;
    
    self.mainTableHeight = 0.0;
    
    self.firstEventsArray = nil;
    self.lastEventsArray = nil;
    
    self.mainChapter = self.chapters[self.currentChapterNum];
    self.mainEventsArray = [self.mainChapter eventsForChapter];
    
    if (self.currentChapterNum > 0) {
        self.firstChapter = self.chapters[self.currentChapterNum - 1];
        self.firstEventsArray = [self.firstChapter eventsForChapter];
    } else {
        self.firstChapter = nil;
    }
 
    if (self.currentChapterNum < self.chapters.count - 1) {
        self.lastChapter = self.chapters[self.currentChapterNum + 1];
        self.lastEventsArray = [self.lastChapter eventsForChapter];
    } else {
        self.lastChapter = nil;
    }
    
    [self loadMainTable];

    
    self.mainTableView.contentOffset = CGPointZero;
    self.firstTableView.contentOffset = CGPointZero;
    self.lastTableView.contentOffset = CGPointZero;
    
    // set the offset of the scroll view to show the main table
    CGPoint currentScroll = CGPointMake(self.scrollView.bounds.size.width, 0.0);
    self.scrollView.contentOffset = currentScroll;
    self.lastScrollX = currentScroll.x;
    
    [self.firstTableView reloadData];
    [self.lastTableView reloadData];
    
    self.mainTableView.scrollEnabled = self.mainChapter.events.count > 0;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.mainChapter.city forKey:LastViewedChapter];
}

#pragma mark - Font Change Notification

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self updateChaptersAndTables];
    [self loadMainTable];
    [self.lastTableView reloadData];
    [self.firstTableView reloadData];
}

#pragma mark - AIGEventHeaderDelegate

- (void)nextChapterButtonTapped
{
    if (self.currentChapterNum < self.chapters.count - 1) {
        self.currentChapterNum++;
    }
    
    CGPoint newOffset = self.scrollView.contentOffset;
    newOffset.x += self.scrollView.bounds.size.width;
    
    self.scrollInitiatedByHeaderButton = YES;

    [UIView animateWithDuration:.5
                     animations:^{
                         [self.scrollView setContentOffset:newOffset animated:NO];
                     } completion:^(BOOL finished) {
                         // switch content
                         [self updateChaptersAndTables];

                         self.scrollInitiatedByHeaderButton = NO;
                         
                         // animate scrolling to main table view
                         CGPoint offset = self.scrollView.contentOffset;
                         offset.x = self.scrollView.bounds.size.width;
                         self.scrollView.contentOffset = offset;

                    }];
}
                                                                                                                                                                        
- (void)previousChapterButtonTapped
{
    if (self.currentChapterNum > 0) {
        self.currentChapterNum--;
    }

    CGPoint newOffset = self.scrollView.contentOffset;
    newOffset.x -= self.scrollView.bounds.size.width;
    
    self.scrollInitiatedByHeaderButton = YES;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.scrollView setContentOffset:newOffset animated:NO];
                     } completion:^(BOOL finished) {
                         [self updateChaptersAndTables];
                         
                         self.scrollInitiatedByHeaderButton = NO;
                     }];
}

#pragma mark - UITabBarControllerDelegate

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController == self.navigationController) {
        if (self.isCurrentlySelected) {
            [self showFirstChapter];
        }
    }
    else {
        self.isCurrentlySelected = NO;
    }
}

@end
