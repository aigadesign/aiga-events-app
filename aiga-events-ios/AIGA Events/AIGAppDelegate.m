//
//  AIGAppDelegate.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGAppDelegate.h"
#import "AIGCoreDataManager.h"
#import "AIGEventListViewController.h"
#import "AIGChapterViewController.h"
#import "AIGCalendarViewController.h"
#import "AIGChapter+Extensions.h"
#import "AIGEvent+Extensions.h"
#import "UIColor+Extensions.h"
#import "AIGEventDataDownloadManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworkReachabilityManager.h"
#import "AIGNotifierView.h"
#import <Parse/Parse.h>
#import "AIGChapterDownloader.h"
#import "NSDate+Extensions.h"
#import "AFNetworkActivityLogger.h"
@interface AIGAppDelegate ()

@end


@implementation AIGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // start of your application:didFinishLaunchingWithOptions // ...
    //[TestFlight takeOff:@"bb4eee1d-9353-4686-8222-29822db1d2c3"];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // set up for reachability monitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
#ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelError ];
#endif
    
    self.window.tintColor = [UIColor aig_LightBlueColor];
    
    [[AIGCoreDataManager sharedCoreDataManager] initialize];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [AIGEvent purgeOldEvents];
    [[AIGCoreDataManager sharedCoreDataManager] saveContextAndWait:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSInteger reachabilityStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        if (reachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
            [AIGNotifierView showNotifierWithMessage:NETWORKUNAVALAIBLEWARNING];
            return;
        }
    });
    
    [self reloadEventDataWithRefreshCompletionHandler:nil];
    [self refreshChapterListWithCompletionHandler:nil];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[AIGCoreDataManager sharedCoreDataManager] cleanup];
}






#pragma mark - App-Wide Data Fetches

- (void)refreshChapterListWithCompletionHandler:(void (^)(NSArray *allChapters, NSError *error))completionHandler
{
    AIGChapterDownloader *downloader = [[AIGChapterDownloader alloc] init];
    [downloader downloadChaptersWithCompletionHandler:^(NSDictionary *responseDict, NSError *error) {
        if (responseDict == nil) {


            if (completionHandler != nil) {
                completionHandler(nil, error);
            }
        }
        
        else {
            dispatch_async(dispatch_get_main_queue(), ^{

                [AIGChapter importChapters:responseDict];
                
                if (completionHandler != nil) {
                    completionHandler([AIGChapter findAll], nil);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ChaptersDoneDownloadingNotification
                                                                    object:nil];
            });
        }
    }];
}

- (void)reloadEventDataWithRefreshCompletionHandler:(void (^)(UIBackgroundFetchResult))refreshCompletionHandler
{
    // reloads the data for the table view
    NSArray *chapters = [AIGChapter selectedChapters];
    __block BOOL newData = NO;
    
    for (AIGChapter *chapter in chapters) {
        NSAssert([chapter isKindOfClass:[AIGChapter class]], @"Chapter parameter needs to be of type AIGChapter");
        
        // get data from Eventbrite
        [[AIGEventDataDownloadManager sharedEventDataDownloadManager]
         downloadEventbriteEventsForChapter:chapter
         completionHandler:^(NSDictionary *responseDict, NSError *error) {
             if (responseDict == nil) {
                 // we've already logged the error so don't bother to here
                 if (refreshCompletionHandler != nil) {
                     refreshCompletionHandler(UIBackgroundFetchResultFailed);
                 }
             } else {
                 [[AIGCoreDataManager sharedCoreDataManager] saveContextAndWait:YES];

                 [AIGEvent importEventbriteEvents:responseDict
                                       forChapter:chapter
                                dataManager:[AIGCoreDataManager sharedCoreDataManager]
                                completionHandler:^(BOOL hasChanges) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (hasChanges) {
                             newData = YES;
                         }
                     });
                 }];
             }
             if (refreshCompletionHandler != nil) {
                 if (newData) {
                     refreshCompletionHandler(UIBackgroundFetchResultNewData);
                 } else {
                     refreshCompletionHandler(UIBackgroundFetchResultNoData);
                 }
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
                 if (refreshCompletionHandler != nil) {
                     refreshCompletionHandler(UIBackgroundFetchResultFailed);
                 }
             } else {

                 [[AIGCoreDataManager sharedCoreDataManager] saveContextAndWait:YES];

                 [AIGEvent importETouchesEvents:responseArray forChapter:chapter completionHandler:^(BOOL hasChanges) {

                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (hasChanges) {
                             newData = YES;
                         }
                     });
                 }];
             }
             
             if (refreshCompletionHandler != nil) {
                 if (newData) {
                     refreshCompletionHandler(UIBackgroundFetchResultNewData);
                 } else {
                     refreshCompletionHandler(UIBackgroundFetchResultNoData);
                 }
             }
         }];

    }
}

#pragma mark - Shared Manager

+ (AIGAppDelegate *)sharedAppDelegate
{
    return [UIApplication sharedApplication].delegate;
}

@end
