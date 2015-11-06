//
//  AIGEventDataDownloadManager.h
//  AIGA Events
//
//  Created by Dennis Birch on 11/5/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIGChapter;

extern NSString *AIGEventDataDownloaderErrorDomain;
typedef NS_ENUM(NSInteger, AIGDataDownloaderErrorType) {
	NoChapterIDError = -1,
    AccessTokenAttemptsTimeout = -2,
};


@interface AIGEventDataDownloadManager : NSObject

@property (nonatomic, strong) NSString *eventBriteAPIKey;
@property (nonatomic, strong) NSString *eTouchesAPIKey;

+ (AIGEventDataDownloadManager *)sharedEventDataDownloadManager;

- (void)downloadEventbriteEventsForChapter:(AIGChapter *)chapter
                           completionHandler:(void (^)(NSDictionary *responseDict, NSError *error))completionHandler;

- (void)downloadETouchesEventsForChapter:(AIGChapter *)chapter startDate:(NSDate *) startDate endDate:(NSDate *)endDate
                       completionHandler:(void (^)(NSArray *responseArray, NSError *error))completionHandler;

- (NSInteger)isLoadingChapterEvents;

- (void)downloadImageForEventWithPath:(NSString *)urlPath
                     completionHandler:(void (^)(UIImage * image, NSError *error))completionHandler;

//- (void)acquireEtouchesAccessToken;

@end
