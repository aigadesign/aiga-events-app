//
//  AIGChapterDownloader.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/20/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGChapterDownloader.h"
#import <Parse/Parse.h>
#import "AIGChapter+Extensions.h"
#import "AIGEventDataDownloadManager.h"

@interface AIGChapterDownloader ()

@property (nonatomic, strong, readwrite) NSDictionary *chaptersDictionary;
@property (nonatomic, assign) NSUInteger downloadAttemptsCount;
@property (nonatomic, strong) NSDate *launchTime;

@end

@implementation AIGChapterDownloader

static int MAX_DOWNLOAD_ATTEMPTS_ALLOWED = 7;
static NSString *DownloadCountKey = @"ChapterDownloadCount";
static NSString *LastDownloadAttemptKey = @"LastChapterDownloadAttempt";

- (instancetype)init
{
    self = [super init];
    if (self) {
        [Parse setApplicationId:kParseAppID clientKey:kParseClientID];
        // obtain attempts count and store in class property on init
        self.downloadAttemptsCount = [[NSUserDefaults standardUserDefaults] integerForKey:DownloadCountKey];
        self.launchTime = [NSDate date];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.downloadAttemptsCount forKey:DownloadCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)updateLastAttemptDate
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastDownloadAttemptKey];
}

- (void)downloadChaptersWithCompletionHandler:(void (^)(NSDictionary *responseDict, NSError *error))completionHandler
{
    // throttle use to no more than 7 attempts within a 24-hour period
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:LastChapterDownloadDate];
    NSTimeInterval lastInterval = [lastDate timeIntervalSinceReferenceDate];

    // check to see if attempt was within last five seconds, and reject it if so (allowing 10 seconds for new app to launch)
    NSDate *lastAttemptDate = [[NSUserDefaults standardUserDefaults] objectForKey:LastDownloadAttemptKey];
    if (lastAttemptDate != nil &&
        [[NSDate date] timeIntervalSinceReferenceDate] - [self.launchTime timeIntervalSinceReferenceDate] > 10 &&
        [[NSDate date] timeIntervalSinceReferenceDate] - [lastAttemptDate timeIntervalSinceReferenceDate] < 5) {
        [self updateLastAttemptDate];
        NSError *error = [[NSError alloc] initWithDomain:ChapterDownloadErrorDomain
                                                    code:ChapterDownloadErrorTooFrequentAttempts
                                                userInfo:nil];
        completionHandler(nil, error);
        return;
    }
    
    
    [self updateLastAttemptDate];
    
    if (lastInterval == 0) {
        // first use, so save the date
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:LastChapterDownloadDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSTimeInterval currentalInterval = [[NSDate date] timeIntervalSinceReferenceDate];
    static NSTimeInterval secondsPerDay = 24 * 60 * 60;
    if (currentalInterval - lastInterval < secondsPerDay) {
        // we're within a 24 period, so update count
        if (self.downloadAttemptsCount > MAX_DOWNLOAD_ATTEMPTS_ALLOWED) {
            NSError *error = [[NSError alloc]initWithDomain:ChapterDownloadErrorDomain
                                                       code:ChapterDownloadErrorExceeded24HourMaximum
                                                   userInfo:@{LastChapterDownloadDate : lastDate}];
            completionHandler(nil, error);
            return;
        }

    } else {
        // we're past the 24 hour period, so set a new one
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:LastChapterDownloadDate];
        // and reset downloads count
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:DownloadCountKey];
        self.downloadAttemptsCount = 0;
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    DLog(@"Querying Parse for Chapter list");
    
    PFQuery *query = [PFQuery queryWithClassName:@"AIGAChapter"];
    [query whereKey:@"city" notEqualTo:@""];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *parseError) {
        if (parseError != nil) {
            completionHandler(nil, parseError);
            
        } else {
            for (PFObject *obj in objects) {
                NSString *eventBritesID = [obj valueForKey:@"eventBritesID"];
                if (eventBritesID == nil) {
                    eventBritesID = @"";
                }
                NSNumber *eTouchesID = [obj valueForKey:@"eTouchesID"];
                if (eTouchesID == nil) {
                    eTouchesID = @(NSNotFound);
                }
                
                NSString *city = [obj valueForKey:kParseChapterIDKey];
                dict[city] = @{kEventBriteIDKey : eventBritesID,
                               kETouchesIDKey : eTouchesID};
            }
            
            DLog(@"Downloaded %lu chapters from Parse", (unsigned long)dict.count);
            
            [self downloadAPIKeys];
            
            self.downloadAttemptsCount++;
            completionHandler([dict copy], nil);
        }
    }];
}

-(void)downloadAPIKeys
{
    DLog(@"Querying Parse API Keys");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Keys"];
    
    NSArray *keys = [query findObjects];
    
    for (PFObject *key in keys) {
        NSString *provider = [key valueForKey:@"Name"];
        NSString *apiKey = [key valueForKey:@"Key"];
        
        if ([[provider lowercaseString] isEqualToString:@"eventbrite"]) {
            NSString *eventBriteAPIKey = [[NSUserDefaults standardUserDefaults] objectForKey:LastEventBriteAPIKey];
            if (![apiKey isEqualToString:eventBriteAPIKey]) {
                [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:LastEventBriteAPIKey];
                [AIGEventDataDownloadManager sharedEventDataDownloadManager].eventBriteAPIKey = apiKey;
            }
        }
        else if ([[provider lowercaseString] isEqualToString:@"etouches"]) {
            NSString *eTouchesAPIKey = [[NSUserDefaults standardUserDefaults] objectForKey:LastEtouchesAPIKey];
            if (![apiKey isEqualToString:eTouchesAPIKey]) {
                [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:LastEtouchesAPIKey];
                [AIGEventDataDownloadManager sharedEventDataDownloadManager].eTouchesAPIKey = apiKey;
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
