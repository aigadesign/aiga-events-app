//
//  AIGeTouchesDownloadManager.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/5/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGETouchesDownloadManager.h"
#import "AFNetworking.h"
#import "AIGAppDelegate.h"
//#import "UIImageView+AFNetworking.h"
#import "AIGETouchesHTTPSessionManager.h"

@interface AIGETouchesDownloadManager ()

@property (nonatomic, copy) NSString *etouchesAccessToken;

@end

@implementation AIGETouchesDownloadManager

#pragma mark - Defines
static NSString *ETOUCHES_API_KEY = @"a0a3da4ffc8a3b1549a24ba6992b4eb8d41e864e";
static NSString *ETOUCHES_ACCOUNT_ID = @"2824";
static NSString *ETOUCHES_EVENT_SEARCH_PATH = @"api/v2/global/searchEvents.json";
static NSString *ETOUCHES_EVENT_DETAIL_PATH = @"api/v2/ereg/getEvent.json";

- (instancetype)init
{
    self = [super init];
    if (self) {
         [self acquireEtouchesAccessToken];
    }
    
    return self;
}


+ (AIGETouchesDownloadManager *)sharedEventDataDownloadManager;
{
    static AIGETouchesDownloadManager *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AIGETouchesDownloadManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)acquireEtouchesAccessToken
{
    AIGETouchesHTTPSessionManager *sessionManager = [AIGETouchesHTTPSessionManager sharedETouchesHTTPSessionManager];
    NSString *path = @"api/v2/global/authorize.json";
    NSDictionary *params = @{@"accountid" : ETOUCHES_ACCOUNT_ID,
                             @"key" : ETOUCHES_API_KEY};

    [sessionManager GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
        NSString *token = [responseDict valueForKey:@"accesstoken"];
        if (token == nil) {
            NSLog(@"Error: No token provided");
            return;
        }
        self.etouchesAccessToken = responseDict[@"accesstoken"];
        
//        NSLog(@"ETouches access token: %@", self.etouchesAccessToken);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failed to download access token: %@", [error localizedDescription]);
    }];
}



- (void)downloadEventListForOrganizer:(NSString *)organizerID startDate:(NSDate *) startDate endDate:(NSDate *)endDate
                 completionHandler:(void (^)(NSArray *responseArray, NSError *error))completionHandler
{
    AIGETouchesHTTPSessionManager *sessionManager = [AIGETouchesHTTPSessionManager sharedETouchesHTTPSessionManager];

    // TODO: CHANGE TO USING INCOMING DATES
    NSDictionary *params = @{@"accesstoken" : self.etouchesAccessToken,
                             @"foldername" : organizerID,
                             @"startdate" : @"2013-12-01",
                             @"enddate" : @"2013-12-31"};
    
    __block NSArray *responseArray;
    __weak AIGETouchesDownloadManager *weakSelf = self;
    
    [sessionManager GET:ETOUCHES_EVENT_SEARCH_PATH parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error = nil;
        
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (json == nil) {
            NSLog(@"Error retrieving JSON: %@", [error localizedDescription]);
            completionHandler(nil, error);
            return;
        }

        __block NSArray *resultsArray = [NSArray array];
        
        if ([json isKindOfClass:[NSArray class]]) {
            responseArray = (NSArray *)json;
            
        } else if ([json isKindOfClass:[NSDictionary class]]) {
            responseArray = @[json];
        }

        [weakSelf downloadEventDetails:responseArray completionHandler:^(NSArray *responseArray) {
            resultsArray = responseArray;
        
//        NSLog(@"Results count: %d", responseArray.count);
        completionHandler(resultsArray, error);
        }];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
        completionHandler(nil, error);
    }];
}

- (void)downloadEventDetails:(NSArray *)eventsArray
             completionHandler:(void (^)(NSArray *eventsArray))completionHandler
{
    NSMutableArray *resultsArray = [NSMutableArray array];
    
    __block NSInteger count = 0;
    
    for (NSDictionary *eventDictionary in eventsArray) {
        count++;
        NSString *eventID = [eventDictionary objectForKey:@"eventid"];
        if (eventID == nil) {
            NSLog(@"No event to show");
            continue;
        }
        
        AIGETouchesHTTPSessionManager *sessionManager = [AIGETouchesHTTPSessionManager sharedETouchesHTTPSessionManager];
        
        NSDictionary *params = @{@"accesstoken" : self.etouchesAccessToken,
                                 @"eventid" : eventID
                                 };
        
        [sessionManager GET:ETOUCHES_EVENT_DETAIL_PATH parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSError *error = nil;
            
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            if (json == nil) {
                NSLog(@"Error retrieving JSON: %@", [error localizedDescription]);
            }
            
             if ([json isKindOfClass:[NSDictionary class]]) {
                [resultsArray addObject:json];
                 if (count >= eventsArray.count) {
                     completionHandler([resultsArray copy]);
                 }
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Failure: %@", [error localizedDescription]);
            if (count >= eventsArray.count) {
                completionHandler([resultsArray copy]);
            }
        }];
    }
    
}


//- (void)downloadImageForEventWithPath:(NSString *)urlPath
//                    completionHandler:(void (^)(UIImage * image, NSError *error))completionHandler
//{
//    NSURL *url = [NSURL URLWithString:urlPath];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPShouldHandleCookies:NO];
//
//    UIImageView *imageView = [[UIImageView alloc] init];
//    
//    [imageView setImageWithURLRequest:request
//                     placeholderImage:nil
//                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                   completionHandler(image, nil);
//    }
//                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                  completionHandler(nil, error);
//                              }];
//}




- (void)downloadFoldersWithCompletionHandler:(void (^)(NSArray *responseArray, NSError *error))completionHandler
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    AIGETouchesHTTPSessionManager *sessionManager = [AIGETouchesHTTPSessionManager sharedETouchesHTTPSessionManager];
    
    NSDictionary *params = @{@"accesstoken" : self.etouchesAccessToken};
    
    __block NSArray *responseArray;
    [sessionManager GET:@"api/v2/global/listFolders.json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error = nil;
        
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (json == nil) {
            NSLog(@"Error retrieving JSON: %@", [error localizedDescription]);
            completionHandler(nil, error);
            return;
        }
        
        if ([json isKindOfClass:[NSArray class]]) {
            responseArray = (NSArray *)json;
            
            completionHandler(responseArray, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
        completionHandler(nil, error);
    }];
}


/*
 
 {
 accountid = 2824;
 advancedsettings = "<null>";
 "calendar_city" = "<null>";
 "calendar_country" = "<null>";
 city = "<null>";
 clientcontact = "http://www.eiseverywhere.com/image.php?acc=2824&amp;id=220476";
 closedate = "2013-12-04";
 closetime = "12:00:00";
 code = BASIC;
 colorsandfonts = "<null>";
 contactinfo = "<null>";
 country = "<null>";
 created = "<null>";
 createdby = "<null>";
 createddatetime = "2013-10-24 21:57:58";
 "currency_dec_point" = "<null>";
 "currency_thousands_sep" = "<null>";
 customfields =     (
 {
 fieldid = 190;
 fieldname = "";
 value = "";
 }
 );
 dateformat = "<null>";
 defaultlanguage = eng;
 deleted = "<null>";
 description = "Spend an evening learning about 3D printing (and watching it in action) with AIGA DC and iStrategyLabs! ";
 eMobile = "<null>";
 eReg = "<null>";
 eSelect = "<null>";
 eSocial = "<null>";
 enddate = "2013-12-04";
 endtime = "20:30:00";
 eventclosemessage = "We're sorry, online registration for this event is closed. Tickets will be available at the door.";
 eventid = 75850;
 eventlogo = "<null>";
 folderid = 9555;
 foldername = "Washington, DC";
 homepage = "http://dc.aiga.org/upcoming-events/";
 ipreoid = "<null>";
 languages = "<null>";
 lastmodified = "<null>";
 "line_item_tax" = "<null>";
 location =     {
 address1 = "1630 Connecticut Ave NW";
 address2 = "";
 address3 = "";
 city = Washington;
 country = "";
 email = "";
 map = "https://maps.google.com/maps?ie=UTF-8&amp;q=iStrategyLabs&amp;fb=1&amp;gl=us&amp;hq=iStrategyLabs&amp;cid=0,0,17353086900491325317&amp;ei=idBpUsniEu3j4AP8joG4Cw&amp;ved=0CKgBEPwSMA4";
 name = "iStrategy Labs";
 phone = "";
 postcode = 20009;
 state = DC;
 };
 locationname = "<null>";
 "look_template" = "<null>";
 modifiedby = "<null>";
 modifieddatetime = "2013-11-20 11:18:22";
 name = "Designing in Another Dimension";
 preloadsettings = "<null>";
 programmanager = "http://www.eiseverywhere.com/image.php?acc=2824&amp;id=220475";
 standardcurrency = "<null>";
 startdate = "2013-12-04";
 starttime = "19:00:00";
 state = "<null>";
 status = Live;
 timeformat = "<null>";
 timezone = "[GMT-05:00] Eastern Time (US & Canada)";
 timezoneid = 14;
 url = "https://www.eiseverywhere.com/75850";
 }
 
 
 ETOUCHES EVENT RESPONSE DICTIONARY (W/O CUSTOM FIELDS)
 
 {
 accountid = 2824;
 advancedsettings = "<null>";
 "calendar_city" = "<null>";
 "calendar_country" = "<null>";
 city = "<null>";
 clientcontact = "http://www.eiseverywhere.com/image.php?acc=2824&amp;id=220476";
 closedate = "2013-12-04";
 closetime = "12:00:00";
 code = BASIC;
 colorsandfonts = "<null>";
 contactinfo = "<null>";
 country = "<null>";
 created = "<null>";
 createdby = "<null>";
 createddatetime = "2013-10-24 21:57:58";
 "currency_dec_point" = "<null>";
 "currency_thousands_sep" = "<null>";
 dateformat = "<null>";
 defaultlanguage = eng;
 deleted = "<null>";
 description = "Spend an evening learning about 3D printing (and watching it in action) with AIGA DC and iStrategyLabs! ";
 eMobile = "<null>";
 eReg = "<null>";
 eSelect = "<null>";
 eSocial = "<null>";
 enddate = "2013-12-04";
 endtime = "20:30:00";
 eventclosemessage = "We're sorry, online registration for this event is closed. Tickets will be available at the door.";
 eventid = 75850;
 eventlogo = "<null>";
 folderid = 9555;
 foldername = "Washington, DC";
 homepage = "http://dc.aiga.org/upcoming-events/";
 ipreoid = "<null>";
 languages = "<null>";
 lastmodified = "<null>";
 "line_item_tax" = "<null>";
 location =     {
 address1 = "1630 Connecticut Ave NW";
 address2 = "";
 address3 = "";
 city = Washington;
 country = "";
 email = "";
 map = "https://maps.google.com/maps?ie=UTF-8&amp;q=iStrategyLabs&amp;fb=1&amp;gl=us&amp;hq=iStrategyLabs&amp;cid=0,0,17353086900491325317&amp;ei=idBpUsniEu3j4AP8joG4Cw&amp;ved=0CKgBEPwSMA4";
 name = "iStrategy Labs";
 phone = "";
 postcode = 20009;
 state = DC;
 };
 locationname = "<null>";
 "look_template" = "<null>";
 modifiedby = "<null>";
 modifieddatetime = "2013-11-20 11:18:22";
 name = "Designing in Another Dimension";
 preloadsettings = "<null>";
 programmanager = "http://www.eiseverywhere.com/image.php?acc=2824&amp;id=220475";
 standardcurrency = "<null>";
 startdate = "2013-12-04";
 starttime = "19:00:00";
 state = "<null>";
 status = Live;
 timeformat = "<null>";
 timezone = "[GMT-05:00] Eastern Time (US & Canada)";
 timezoneid = 14;
 url = "https://www.eiseverywhere.com/75850";
 }

*/

@end
