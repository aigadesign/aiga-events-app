
//
//  AIGEventDetailViewController.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/29/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventDetailViewController.h"
#import "AIGEvent+Extensions.h"
#import "AIGEventCell+Geometry.h"
#import "AIGMapViewController.h"
#import "UIColor+Extensions.h"
#import "UIFont+AIGAExtensions.h"
#import "AIGEventDetailLocationTimeView.h"
#import "NSString+HTML.h"


@import EventKit;
@import EventKitUI;
@import CoreLocation;

@interface AIGEventDetailViewController () <EKEventEditViewDelegate, DetailLocationTimeViewDelegate, UIScrollViewDelegate, UIWebViewDelegate>


@property (nonatomic, strong) UIWebView *detailContentView;

@property (nonatomic, strong) UIImageView *mainImageView;

@property (nonatomic, weak) IBOutlet UIScrollView *bodyScrollView;

@property (nonatomic, strong) AIGEventDetailLocationTimeView *locationTimeView;

@end

@implementation AIGEventDetailViewController

static NSString *DisplayMapSegue = @"DisplayMapSegue";

#pragma mark - ViewController Life Cycle Methods

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
    
    self.bodyScrollView.delegate = self;
    self.bodyScrollView.bounces = YES;

    // create mainImageView with a default size frame
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200.0)];
    self.mainImageView = imageView;
    [self.bodyScrollView addSubview:self.mainImageView];

    self.view.backgroundColor = [UIColor aig_TableViewBackgroundColor];

    // add web view for description content
    self.detailContentView = [[UIWebView alloc] init];
    self.detailContentView.backgroundColor = self.view.backgroundColor;
    self.detailContentView.opaque = NO;
    [self.bodyScrollView addSubview:self.detailContentView];
    
    // create locationTimeView with a default size frame
    // NOTE: adding it after web view so its shadow will appear over web view's content
    CGRect frame = CGRectMake(0.0, 200.0, self.view.bounds.size.width, 110.0);
    self.locationTimeView = [[AIGEventDetailLocationTimeView alloc] initWithFrame:frame];
    [self.bodyScrollView addSubview:self.locationTimeView];
    self.locationTimeView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    self.detailContentView.scrollView.scrollEnabled = NO;
}

- (void)dealloc
{
    self.bodyScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self.currentEvent mainImage]];
    CGRect imageFrame = imageView.frame;
    
    CGFloat scaleValue = self.bodyScrollView.bounds.size.width/imageFrame.size.width;
    imageFrame.size.width *= scaleValue;
    imageFrame.size.height *= scaleValue;
    
    imageView.frame = imageFrame;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.mainImageView = imageView;
    self.mainImageView.image = [self.currentEvent mainImage];
    
    [self.bodyScrollView addSubview:self.mainImageView];
    
    // readjust locationTimeView frame top
    CGRect locationTimeViewFrame = self.locationTimeView.frame;
    locationTimeViewFrame.origin.y = imageFrame.origin.y + imageFrame.size.height;
    self.locationTimeView.frame = locationTimeViewFrame;
    
    // add stylized title view
    self.title = NSLocalizedString(@"EVENT DETAILS", nil);

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    label.font = [UIFont fontWithName:@"Interstate-Light" size:18];
    label.textColor = [UIColor aig_DarkBlackColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.title;
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    // load webView text
    NSURL *mainBundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSError *error = nil;
    static NSString *htmlString;
    if (htmlString == nil) {
        htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (htmlString == nil) {
            NSLog(@"Error opening index.html: %@", [error localizedDescription]);
        }
    }
    
    NSString *replacedString = [htmlString stringByReplacingOccurrencesOfString:@"{{body}}" withString:self.currentEvent.eventDescription];
    [self.detailContentView loadHTMLString:replacedString baseURL:mainBundleURL];
    
    [self configureTextElements];

    self.detailContentView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.detailContentView.delegate = self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set Up Geometry

- (void)configureTextElements
{
    self.locationTimeView.currentEvent = self.currentEvent;

    CGSize locationTimeViewSize = [self.locationTimeView sizeThatFits:self.view.frame.size];
    CGRect locationTimeViewFrame = self.locationTimeView.frame;
    locationTimeViewFrame.size = locationTimeViewSize;
    self.locationTimeView.frame = locationTimeViewFrame;
    
    CGFloat topOfWebView = locationTimeViewFrame.origin.y + locationTimeViewFrame.size.height;

    // set detailContentView geometry
    CGFloat detailsHeight = self.mainImageView.bounds.size.height ;
    self.detailContentView.frame = CGRectMake(0,
                                              topOfWebView,
                                              self.bodyScrollView.bounds.size.width,
                                              detailsHeight + 49);

    // set scrollView's contentSize
    CGFloat imageHeight = self.mainImageView.frame.size.height;
    CGSize scrollSize = CGSizeMake(self.bodyScrollView.bounds.size.width, self.bodyScrollView.bounds.size.height + imageHeight - 64.0);
    self.bodyScrollView.contentSize = scrollSize;

    // don't show scroll indicators
    self.detailContentView.scrollView.showsHorizontalScrollIndicator = NO;
    self.detailContentView.scrollView.showsVerticalScrollIndicator = NO;
    // don't scroll web view
    self.detailContentView.scrollView.scrollEnabled = NO;
    //Disable bouncing in webview
    self.detailContentView.scrollView.bounces = NO;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:DisplayMapSegue]) {
        AIGMapViewController *vc = segue.destinationViewController;
        vc.venueLocation = self.currentEvent.eventLocation;
    }
}


#pragma mark - Actions


- (void)mapButtonTouched
{
    [self performSegueWithIdentifier:DisplayMapSegue sender:self];
}

- (void)calendarButtonTapped
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            EKCalendar *defaultCalendar = [store defaultCalendarForNewEvents];
            
            EKEvent *calEvent = [EKEvent eventWithEventStore:store];
            
            calEvent.title = self.currentEvent.eventTitle;
            calEvent.startDate = self.currentEvent.startTime;
            calEvent.endDate = self.currentEvent.endTime;
            NSString *location = self.currentEvent.venueName != nil ? self.currentEvent.venueName : @"";
            location = [location kv_decodeHTMLCharacterEntities];
            if (self.currentEvent.venueName != nil && self.currentEvent.address != nil) {
                location = [location stringByAppendingString:@" — "];
            }
            if (self.currentEvent.address != nil) {
                location = [location stringByAppendingString:[self.currentEvent trimmedAddress]];
            }
            calEvent.location = location;
            calEvent.allDay = NO;
            calEvent.notes = self.currentEvent.abbrevDescription;
            calEvent.calendar = defaultCalendar;
            [calEvent addAlarm:[EKAlarm alarmWithRelativeOffset:-1800]];
            
            EKEventEditViewController *evtVC = [[EKEventEditViewController alloc] init];
            evtVC.eventStore = store;
            evtVC.editViewDelegate = self;
            evtVC.event = calEvent;
            
            [self performSelectorOnMainThread:@selector(showEventVC:) withObject:evtVC waitUntilDone:NO];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(showCalendarDeniedAlert) withObject:nil waitUntilDone:NO];
        }
    }];
}

-(void)showEventVC:(EKEventEditViewController *)vc
{
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)showCalendarDeniedAlert
{
    NSString *message = @"In order to add events to your Calendar, you need to authorize 'AIGA Events' in Settings>Privacy>Calendars.";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Need Calendar Authorization"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)registerButtonTapped
{
    NSString *urlPath = self.currentEvent.registerURL;
    
    NSURL *url = [NSURL URLWithString:urlPath];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Text Size Change Notifications

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    self.locationTimeView.currentEvent = self.currentEvent;
    [self configureTextElements];
}


#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


#pragma mark - UIWebViewDelegate

- (BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
         [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect webFrame = webView.frame;
    webFrame.size.height = 1;
    webView.frame = webFrame;
    CGSize webContentSize = [webView sizeThatFits:CGSizeZero];
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    if (height > webContentSize.height) {
        webContentSize.height = height;
    }
    webFrame.size.height = webContentSize.height;
    webView.frame = webFrame;

    NSUInteger navHeight = self.navigationController.navigationBar.frame.size.height +
        self.navigationController.navigationBar.frame.origin.y;
    NSUInteger scrollHeight = webFrame.origin.y - navHeight + webFrame.size.height;
    CGSize size = CGSizeMake(self.bodyScrollView.contentSize.width, scrollHeight);
    self.bodyScrollView.contentSize = size;
    [self.bodyScrollView layoutIfNeeded];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}


@end
