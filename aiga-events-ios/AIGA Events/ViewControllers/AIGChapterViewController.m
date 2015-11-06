//
//  AIGChapterViewController.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGChapterViewController.h"
#import "AIGAppDelegate.h"
#import "AIGChapter+Extensions.h"
#import "AIGEvent+Extensions.h"
#import "AIGCoreDataManager.h"
#import "AIGActivityIndicator.h"
#import "AIGChapterDownloader.h"
#import "AIGEventDataDownloadManager.h"
#import "AIGNotifierView.h"
#import "AFNetworkReachabilityManager.h"
#import "UIColor+Extensions.h"
#import "UIFont+AIGAExtensions.h"

@interface AIGChapterViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger selectedCount;
@property (nonatomic, strong) NSDictionary *chaptersDict;
@property (nonatomic, strong) NSArray *sortedInitialsArray;
@property (nonatomic, strong) NSArray *chapterNames;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) AIGActivityIndicator *activityIndicator;
@property (nonatomic, strong) UIView *infoView;

@property (nonatomic, strong) UIImage *check;

@end

@implementation AIGChapterViewController

static NSString *fullAlphabet = @"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.check = [UIImage imageNamed:@"check"];
    
   // Refresh button
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(refreshChapterList)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    
    // get names of chapters user has marked for tracking
    self.chapterNames = [AIGChapter findAll];
    self.chaptersDict = [AIGChapter chaptersDict];
    self.sortedInitialsArray = [AIGChapter sortedChapterInitials];
    
    // and initiate a download to see if we need to make changes
    [self refreshChapterList];


    // set up for text size change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable:)
                                                 name:ChaptersDoneDownloadingNotification
                                               object:nil];
    
    self.title = NSLocalizedString(@"CHAPTERS", nil);
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    label.font = [UIFont fontWithName:@"Interstate-Light" size:18];
    label.textColor = [UIColor aig_DarkBlackColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.title;
    [label sizeToFit];
    self.navigationItem.titleView = label;

    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    self.activityIndicator = [[AIGActivityIndicator alloc] initWithFrame:self.view.frame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = 42;
    self.tableView.separatorColor = [UIColor aig_ChapterListSeparatorColor];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HASDISPLAYEDGETSTARTEDVIEW]) {
        [self displayFirstLaunchInfoView];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.infoView) {
        [self.infoView removeFromSuperview];
        self.infoView = nil;
    }
    [self sendChapterChangeNotification];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - First Launch

- (void)displayFirstLaunchInfoView
{
    CGRect frame = self.view.frame;
    UIView *infoView = [[UIView alloc] initWithFrame:frame];
    
    infoView.backgroundColor = [UIColor whiteColor];
    
    frame = CGRectInset(infoView.bounds, 45.0, 204.0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.textColor = [UIColor aig_MediumLightGrayColor];
    label.font = [UIFont aig_RegularFontOfSize:16.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"To display events please select one or more AIGA Chapters.";
    [label sizeToFit];
    [infoView addSubview:label];

    CGFloat viewWidth = self.view.bounds.size.width;
    
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowButton setImage:[UIImage imageNamed:@"get-started-arrow"] forState:UIControlStateNormal];
    [arrowButton addTarget:self action:@selector(closeInfoView) forControlEvents:UIControlEventTouchUpInside];
    [arrowButton sizeToFit];
    frame = arrowButton.frame;
    frame.origin.x = viewWidth - frame.size.width - 25.0;
    frame.origin.y = label.frame.origin.y + frame.size.height + 24.0;
    arrowButton.frame = frame;
    [infoView addSubview:arrowButton];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIFont *font = [UIFont aig_RegularFontOfSize:13.5];
    NSDictionary *attributes = @{NSFontAttributeName : font};
    NSAttributedString *buttonCaption = [[NSAttributedString alloc] initWithString:@"GET STARTED" attributes:attributes];
    [closeButton setAttributedTitle:buttonCaption forState:UIControlStateNormal];
    [closeButton sizeToFit];
    frame = closeButton.frame;
    frame.origin.x = arrowButton.frame.origin.x - frame.size.width - 4.0;
    frame.origin.y = arrowButton.frame.origin.y;
    closeButton.frame = frame;
    [closeButton addTarget:self action:@selector(closeInfoView) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:closeButton];
    
    self.infoView = infoView;
    [self.view addSubview:self.infoView];
}

- (void)closeInfoView
{
    [self.infoView removeFromSuperview];
    self.infoView = nil;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HASDISPLAYEDGETSTARTEDVIEW];
}

# pragma mark - Downloading Chapters

- (void)refreshTable:(NSNotification *)notification
{
    self.chaptersDict = [AIGChapter chaptersDict];
    self.sortedInitialsArray = [AIGChapter sortedChapterInitials];
    [self.tableView reloadData];
}

- (void)refreshChapterList
{
    NSInteger networkStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (networkStatus == AFNetworkReachabilityStatusNotReachable) {
         [AIGNotifierView showNotifierWithMessage:NETWORKUNAVALAIBLEWARNING];
        return;
    }

    [self showActivityIndicator];
    
    [[AIGAppDelegate sharedAppDelegate] refreshChapterListWithCompletionHandler:^(NSArray *allChapters, NSError *error) {
        if (allChapters == nil) {
            [self hideActivityIndicator];
            
            // show an error alert unless it's because of user abuse or the system trying too often
            if (![error.domain isEqualToString:ChapterDownloadErrorDomain]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"There was an error loading chapters. Please try again later."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }
 
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.chaptersDict = [AIGChapter chaptersDict];
                self.sortedInitialsArray = [AIGChapter sortedChapterInitials];
                [self hideActivityIndicator];

                [self.tableView reloadData];
            });
        }
        
    }];
}

#pragma mark - Activity Indicator

- (void)showActivityIndicator
{
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator show];
}

- (void)hideActivityIndicator
{
    [self.activityIndicator hide];
}

#pragma mark - Chapter Change Notification

- (void)sendChapterChangeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ChapterSelectionsChangedNotification
                                                        object:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.chaptersDict.count;
}

- (NSArray *)namesArrayForSection:(NSInteger)section
{
    NSArray *initials = [AIGChapter sortedChapterInitials];
    
    NSString *key = initials[section];
    
    return self.chaptersDict[key];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *chaptersArray = [self namesArrayForSection:section];
    return chaptersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor aig_TableViewBackgroundColor];
    cell.backgroundColor = [UIColor aig_TableViewBackgroundColor];
    
    NSArray *chaptersArray = [self namesArrayForSection:indexPath.section];
    AIGChapter *chapter = chaptersArray[indexPath.row];
    
    cell.textLabel.text = chapter.city;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.font = [UIFont fontWithName:@"Interstate-Regular" size:16];
    cell.textLabel.textColor = [UIColor aig_MediumLightGrayColor];;
    
    if (chapter.selected) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.check];
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (IBAction)displayEvents:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [fullAlphabet componentsSeparatedByString:@","];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    NSInteger idx = [self.sortedInitialsArray indexOfObject:title];
    if (idx == NSNotFound) {
        NSInteger decrementer = index - 1;
        NSString *sortedInitial;

        if (decrementer >= self.sortedInitialsArray.count) {
            decrementer = self.sortedInitialsArray.count - 1;
            sortedInitial = @"Z";
        } else {
            sortedInitial = self.sortedInitialsArray[decrementer];
        }

        while ([sortedInitial compare:title] == NSOrderedDescending) {
            decrementer--;
            sortedInitial = self.sortedInitialsArray[decrementer];
        }

        idx = decrementer;
    }
    
    return idx;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sortedInitialsArray[section];
}

#pragma  mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *initial = self.sortedInitialsArray[indexPath.section];
    AIGChapter *chapter = self.chaptersDict[initial][indexPath.row];
    chapter.selected = !chapter.selected;
    
    [[AIGCoreDataManager sharedCoreDataManager] saveContextAndWait:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (chapter.selected) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.check];

        // Kick off event data download for chapter
        [self initiateEventDownloadForChapter:chapter];
        
    } else {
        cell.accessoryView = nil;
    }
    
    [self sendChapterChangeNotification];

    // no row highlight needed
    return nil;
}

- (void)initiateEventDownloadForChapter:(AIGChapter *)chapter
{
    NSAssert([chapter isKindOfClass:[AIGChapter class]], @"Chapter parameter needs to be of type AIGChapter");
    
    // get Eventbrites data
    [[AIGEventDataDownloadManager sharedEventDataDownloadManager]
     downloadEventbriteEventsForChapter:chapter
     completionHandler:^(NSDictionary *responseDict, NSError *error) {
         if (responseDict == nil) {
             // we've already logged the error
         } else {
             [AIGEvent importEventbriteEvents:responseDict forChapter:chapter
                                  dataManager:[AIGCoreDataManager sharedCoreDataManager]
                            completionHandler:^(BOOL hasChanges) {
                                [self sendChapterChangeNotification];
             }];
         }
     }];
    
    // get data from ETouches
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [NSDate distantFuture];
    [[AIGEventDataDownloadManager sharedEventDataDownloadManager]
     downloadETouchesEventsForChapter:chapter startDate:startDate endDate:endDate
     completionHandler:^(NSArray *responseArray, NSError *error) {
         if (responseArray == nil) {
             // we've already logged the error so don't bother to here
         } else {
             [AIGEvent importETouchesEvents:responseArray forChapter:chapter completionHandler:^(BOOL hasChanges) {
                 [self sendChapterChangeNotification];
             }];
         }
     }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 20.0)];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    frame.origin.x = 16.0;
    frame.origin.y = 3.0;
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor aig_MediumLightGrayColor];
    label.font = [UIFont fontWithName:@"Interstate-Regular" size:16];
    label.text = self.sortedInitialsArray[section];
    [view addSubview:label];
    
    return view;
}


- (void)configureFonts
{
    
}

#pragma mark - Text Size Change Notifications

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}


@end
