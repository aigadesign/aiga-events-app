//
//  AIGEventDataDownloadManager.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/5/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventDataDownloadManager.h"
#import "AIGAEventsDefines.h"
#import "AIGEventbriteHTTPSessionManager.h"
#import "AIGETouchesHTTPSessionManager.h"
#import "AFNetworking.h"
#import "AIGAppDelegate.h"
#import "AIGEventListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+Extensions.h"

#import "AIGChapter.h"
#import "AIGCoreDataManager.h"

NSString *AIGEventDataDownloaderErrorDomain = @"AIGCoreDataManagerErrorDomain";
NSString *LastEtouchesAccessTokenKey = @"LastEtouchesAccessToken";


@interface AIGEventDataDownloadManager ()

@property (nonatomic, copy) NSString *etouchesAccessToken;
@property (nonatomic, assign) int accessTokenAttempts;

@property (nonatomic, strong) NSMutableDictionary *chaptersLoadingEtouches;
@property (nonatomic, strong) NSMutableDictionary *chaptersLoadingEventbrite;
@property (nonatomic) NSInteger chaptersLoadingTotal;

@end

@implementation AIGEventDataDownloadManager

#pragma mark - Eventbrite Defines
static NSString *EVENTBRITE_EVENT_SEARCH_PATH = @"json/event_search";

// this is the latest API key provided by Tiia
static NSString *EVENTBRITE_IMAGE_URL = @"http://ebmedia.eventbrite.com/";

#pragma mark - ETouches Defines
static NSString *ETOUCHES_ACCOUNT_ID = @"2824";
static NSString *ETOUCHES_EVENT_SEARCH_PATH = @"api/v2/global/searchEvents.json";
static NSString *ETOUCHES_EVENT_DETAIL_PATH = @"api/v2/ereg/getEvent.json";


#pragma mark - Singleton

+ (AIGEventDataDownloadManager *)sharedEventDataDownloadManager;
{
    static AIGEventDataDownloadManager *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AIGEventDataDownloadManager alloc] init];
        sharedInstance.etouchesAccessToken = [[NSUserDefaults standardUserDefaults] stringForKey:LastEtouchesAccessTokenKey];
        sharedInstance.eventBriteAPIKey = [[NSUserDefaults standardUserDefaults] stringForKey:LastEventBriteAPIKey];
        sharedInstance.eTouchesAPIKey = [[NSUserDefaults standardUserDefaults] stringForKey:LastEtouchesAPIKey];
        sharedInstance.chaptersLoadingEtouches = [[NSMutableDictionary alloc] init];
        sharedInstance.chaptersLoadingEventbrite = [[NSMutableDictionary alloc] init];
        sharedInstance.chaptersLoadingTotal = 0;
    });
    
    return sharedInstance;
}

-(void)setEventBriteAPIKey:(NSString *)eventBriteAPIKey
{
    if (![eventBriteAPIKey isEqualToString:_eventBriteAPIKey]) {
        _eventBriteAPIKey = eventBriteAPIKey;
    }
}

-(void)setETouchesAPIKey:(NSString *)eTouchesAPIKey
{
    if (![eTouchesAPIKey isEqualToString:_eTouchesAPIKey]) {
        _eTouchesAPIKey = eTouchesAPIKey;
    }
}

#pragma mark - Chapter/busy tracking

- (void)incrementLoadingCountForChapter:(NSString *)chapterCity inDictionary:(NSMutableDictionary *)dict byCount:(NSInteger)incr
{
    NSNumber *loadingCount = dict[chapterCity];
    loadingCount = @(loadingCount.intValue + incr);
    dict[chapterCity] = loadingCount;
    self.chaptersLoadingTotal += incr;
    NSLog(@"ChaptersLoadingTotal=%ld after + %ld on %@ in %@",(long)self.chaptersLoadingTotal, (long)incr, chapterCity, (dict==self.chaptersLoadingEtouches)?@"Etouches":@"Eventbrite");
    if (self.chaptersLoadingTotal==0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:EventsDoneDownloadingNotification
                                                            object:self];
    }
}

- (NSInteger)isLoadingChapterEvents
{
    return (self.chaptersLoadingTotal>0);
}

#pragma mark - Eventbrites Event Data

- (void)downloadEventbriteEventsForChapter:(AIGChapter *)chapter
                 completionHandler:(void (^)(NSDictionary *responseDict, NSError *error))completionHandler
{
    __weak AIGEventDataDownloadManager *weakSelf = self;
    
    NSString *organizerID = chapter.eventBriteOrg;
    if (organizerID == nil || [organizerID isEqualToString:@""] || !self.eventBriteAPIKey || !self.eTouchesAPIKey) {
        return;
    }
    
    AIGEventbriteHTTPSessionManager *sessionManager = [AIGEventbriteHTTPSessionManager sharedEventbriteHTTPSessionManager];
    
    NSDictionary *params = @{@"organizer" : organizerID,
                             @"app_key" : self.eventBriteAPIKey};
    
    [self incrementLoadingCountForChapter:chapter.city inDictionary:self.chaptersLoadingEventbrite byCount:1];
    
    void (^postSuccessBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDictionary;
        NSError *error = nil;
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        
        NSLog(@"In Eventbrite postSuccessBlock");
        if ([json isKindOfClass:[NSDictionary class]]) {
            responseDictionary = (NSDictionary *)json;
        }
        
        if (responseDictionary == nil || responseDictionary[@"error"]) {
            NSLog(@"Error retrieving Eventbrite JSON: %@", [error localizedDescription]);
            completionHandler(nil, error);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(responseDictionary, error);
            });
        }
        [weakSelf incrementLoadingCountForChapter:chapter.city inDictionary:self.chaptersLoadingEventbrite byCount:-1];
    };
    
    //For debugging, use this instead of postSuccessBlock to delay processing the returned data.
    //    void (^delayedPostSuccessBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject) {
    //        int waitSeconds = 1;
    //        NSLog(@"In Eventbrite delayedPostSuccessBlock, waiting for %d seconds", waitSeconds);
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    //            postSuccessBlock(task, responseObject);
    //        });
    //    };
    
    [sessionManager POST:EVENTBRITE_EVENT_SEARCH_PATH parameters:params success:postSuccessBlock failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
        completionHandler(nil, error);
        [weakSelf incrementLoadingCountForChapter:chapter.city inDictionary:self.chaptersLoadingEventbrite byCount:-1];
    }];
}


#pragma mark - Download Images

- (void)downloadImageForEventWithPath:(NSString *)urlPath
                    completionHandler:(void (^)(UIImage * image, NSError *error))completionHandler
{
    NSURL *url = [NSURL URLWithString:urlPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];

    UIImageView *imageView = [[UIImageView alloc] init];
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   completionHandler(image, nil);
    }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  completionHandler(nil, error);
                              }];
}


#pragma mark - ETouches Download Methods

// Access Token acquired at 2013-12-10 14:25
// 0lfcaGnBuYmPAleiiRii3htRCDunipcQq5dbIZcgBisDpqCtWrrkbmfipFKkP3vDWNy1FisOkhm5lE4fxU5rMG3rtEvgieie

- (void)downloadETouchesEventsForChapter:(AIGChapter *)chapter startDate:(NSDate *) startDate endDate:(NSDate *)endDate
                    completionHandler:(void (^)(NSArray *responseArray, NSError *error))completionHandler
{
    __weak AIGEventDataDownloadManager *weakSelf = self;
    
    NSString *chapterID = chapter.eTouchesID;
    
    if (self.etouchesAccessToken == nil) {
        // send a blank token, which will trigger an error response, forcing a request for a new token, which will
        // then re-call this method in its completion block after obtaining a new token and setting the property's value
        self.etouchesAccessToken = @"";
    }
    
    if (chapterID == nil) {
        NSError *nilChapterIDError = [[NSError alloc]initWithDomain:AIGEventDataDownloaderErrorDomain code:NoChapterIDError userInfo:@{@"localizedDescription" : @"Nil Chapter ID"}];
        completionHandler(nil, nilChapterIDError);
        return;
    }
    
    AIGETouchesHTTPSessionManager *sessionManager = [AIGETouchesHTTPSessionManager sharedETouchesHTTPSessionManager];
    NSString *startDateStr = [startDate aig_ETouchesDateString];
    NSString *endDateStr = [endDate aig_ETouchesDateString];
    
    NSDictionary *params = @{@"accesstoken" : self.etouchesAccessToken,
                             @"folderid" : chapterID,
                             @"startdate" : startDateStr,
                             @"enddate" : endDateStr};
    
    [self incrementLoadingCountForChapter:chapter.city inDictionary:self.chaptersLoadingEtouches byCount:1];
    
    void (^__block wrappedCompletionHandler)(NSArray *, NSError *) = ^(NSArray *responseArray, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(responseArray, error);
        });
        [weakSelf incrementLoadingCountForChapter:chapter.city inDictionary:self.chaptersLoadingEtouches byCount:-1];
    };
    
    void (^postSuccessBlock)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"In Etouches postSuccessBlock");
        NSError *error = nil;
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (json == nil) {
            NSLog(@"Error retrieving Etouches event list JSON for chapter ID %@: %@", chapterID, [error localizedDescription]);
            wrappedCompletionHandler(nil, error);
            return;
        }
        
        NSArray *responseArray;
        
        if ([json isKindOfClass:[NSArray class]]) {
            responseArray = (NSArray *)json;
            
        } else if ([json isKindOfClass:[NSDictionary class]]) {
            // check for invalid token response
            NSDictionary *serviceErrorDict = (NSDictionary *)json;
            NSObject *errorDetails = serviceErrorDict[@"error"];
            if ([errorDetails isKindOfClass:[NSString class]]) {
                NSLog(@"Error string in place of error dictionary: %@", errorDetails);
                wrappedCompletionHandler(nil, nil);
                return;
            }
            if ([self hasEtouchesAuthorizationError:serviceErrorDict]) {
                [weakSelf acquireEtouchesAccessTokenForSession:chapterID
                                             completionHandler:^(NSError *error) {
                                                 if (error == nil) {
                                                     [weakSelf downloadETouchesEventsForChapter:chapter
                                                                                      startDate:startDate
                                                                                        endDate:endDate
                                                                              completionHandler:wrappedCompletionHandler];
                                                 } else {
                                                     wrappedCompletionHandler(nil, error);
                                                 }
                                             }];
                return;
            }
            
            responseArray = @[json];
        }
        
        [weakSelf downloadEventDetails:responseArray
                             chapterID:chapterID
                     completionHandler:wrappedCompletionHandler];
    };
    
    //For debugging, use this instead of postSuccessBlock to delay processing the returned data.
    //    void (^delayedPostSuccessBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject) {
    //        int waitSeconds = 1.5;
    //        NSLog(@"In Etouches delayedPostSuccessBlock, waiting for %d seconds", waitSeconds);
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    //            postSuccessBlock(task, responseObject);
    //        });
    //    };
    
    [sessionManager GET:ETOUCHES_EVENT_SEARCH_PATH parameters:params success:postSuccessBlock failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
        wrappedCompletionHandler(nil, error);
    }];
}

- (BOOL)hasEtouchesAuthorizationError:(NSDictionary *)serviceErrorDict
{
    if (serviceErrorDict[@"error"] != nil) {
        NSArray *serviceErrorValues = [serviceErrorDict allValues];
        NSString *authError = @"You are not authorized to make that request";
        for (NSDictionary *errDict in serviceErrorValues) {
            NSString *authErrorMsg = errDict[@"authorized"];
            if ([authErrorMsg isEqualToString:authError]) {
                return YES;
            }
        }
    }

    return NO;
}

- (void)downloadEventDetails:(NSArray *)eventsArray
                   chapterID:(NSString *)chapterID
           completionHandler:(void (^)(NSArray *eventsArray, NSError *error))completionHandler
{
    NSMutableArray *resultsArray = [NSMutableArray array];
    NSMutableArray *idsArray = [NSMutableArray array];
    __block NSInteger eventsToRetrieve = eventsArray.count;
    BOOL stillNeedToCallCompletionHandler = YES;

    for (NSDictionary *eventDictionary in eventsArray) {
        
        NSString *eventID = [eventDictionary objectForKey:@"eventid"];
        if (eventID == nil) {
            NSLog(@"No event to show");
            eventsToRetrieve--;
            continue;
        }
        
#if 0
        __weak AIGEventDataDownloadManager *weakSelf = self;

        //downloadEventDetails is only called after we have successfully retrieved a list of events,
        //so we must have a valid access token.
        if (self.etouchesAccessToken == nil) {
            [weakSelf acquireEtouchesAccessTokenForSession:chapterID completionHandler:^(NSError *error) {
                if (error) {
                    // go back to calling method
                    NSLog(@"Error acquiring Etouches access token: %@", error);
                    completionHandler(nil,error);
                }
            }];
        }
#endif
        
        AIGETouchesHTTPSessionManager *sessionManager = [AIGETouchesHTTPSessionManager sharedETouchesHTTPSessionManager];
        
        NSDictionary *params = @{@"accesstoken" : self.etouchesAccessToken,
                                 @"eventid" : eventID
                                 };

        stillNeedToCallCompletionHandler = NO;
        [sessionManager GET:ETOUCHES_EVENT_DETAIL_PATH parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSError *error = nil;
            
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            if (json == nil) {
                NSLog(@"Error retrieving ETouches event detail JSON: %@", [error localizedDescription]);
            }
            
            if ([json isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultDict = (NSDictionary *)json;
                
                [resultsArray addObject:json];
                [idsArray addObject:resultDict[@"eventid"]];
                
                if (resultsArray.count >= eventsToRetrieve) {
                    completionHandler([resultsArray copy],nil);
                }
            }
            else {
                eventsToRetrieve--;
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Failure: %@", [error localizedDescription]);
            eventsToRetrieve--;
            if (resultsArray.count >= eventsToRetrieve) {
                completionHandler([resultsArray copy],nil);
            }
        }];
    }
    if (stillNeedToCallCompletionHandler)
    {
        completionHandler(nil,nil);
    }
}

- (void)acquireEtouchesAccessTokenForSession:(NSString *)chapter
                           completionHandler:(void (^)(NSError *error))completionHandler
{
    AIGETouchesHTTPSessionManager *sessionManager = [AIGETouchesHTTPSessionManager sharedETouchesHTTPSessionManager];
    NSString *path = @"api/v2/global/authorize.json";
    NSDictionary *params = @{@"accountid" : ETOUCHES_ACCOUNT_ID,
                             @"key" : self.eTouchesAPIKey};

    DLog(@"Attempts to acquire access code: %d", self.accessTokenAttempts);
    
    // allow up to seven tries without throwing an error
    if (self.accessTokenAttempts > 6) {
        NSError *attemptsError = [[NSError alloc]initWithDomain:AIGEventDataDownloaderErrorDomain code:AccessTokenAttemptsTimeout userInfo:@{@"localizedDescription" : @"Too many attempts to acquire access token"}];
        completionHandler(attemptsError);
        return;
    }

    self.accessTokenAttempts++;
    
    [sessionManager GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
        NSString *token = [responseDict valueForKey:@"accesstoken"];
        if (token == nil) {
            NSLog(@"Error: No token provided");
            return;
        }
        self.etouchesAccessToken = responseDict[@"accesstoken"];
        [[NSUserDefaults standardUserDefaults] setObject:self.etouchesAccessToken forKey:LastEtouchesAccessTokenKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DLog(@"ETouches access token: %@", self.etouchesAccessToken);
        self.accessTokenAttempts = 0;
        completionHandler(nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failed to download access token: %@", [error localizedDescription]);
        self.accessTokenAttempts = 0;
        completionHandler(error);
    }];
}



/*
 - (NSString *)cleanseHTML:(NSString *)htmlString
 {
 // remove all '\u00a0' sequences and replace with \n
 htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\u00a0" withString:@"\n"];
 
 const char *cStr = [htmlString cStringUsingEncoding:NSUTF8StringEncoding];
 if (cStr != nil) {
 htmlString = [[NSString alloc] initWithCString:cStr encoding:NSUTF8StringEncoding];
 NSLog(@"Converted HTMLString: %@", htmlString);
 
 NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
 
 NSDictionary *options = @{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType};
 NSError *error;
 NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:htmlData options:options documentAttributes:nil error:&error];
 if (attributedString == nil) {
 NSLog(@"Error converting HTML to text: %@\nHTML:%@", [error localizedDescription], htmlString);
 }
 }
 
 return htmlString;
 }
 
*/

@end
