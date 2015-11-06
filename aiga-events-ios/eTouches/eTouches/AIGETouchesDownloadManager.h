//
//  AIGeTouchesDownloadManager.h
//  AIGA Events
//
//  Created by Dennis Birch on 11/5/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIGETouchesDownloadManager : NSObject

+ (AIGETouchesDownloadManager *)sharedEventDataDownloadManager;

- (void)downloadEventListForOrganizer:(NSString *)organizerID startDate:(NSDate *) startDate endDate:(NSDate *)endDate
                    completionHandler:(void (^)(NSArray *responseArray, NSError *error))completionHandler;

- (void)downloadImageForEventWithPath:(NSString *)urlPath
                     completionHandler:(void (^)(UIImage * image, NSError *error))completionHandler;




- (void)downloadFoldersWithCompletionHandler:(void (^)(NSArray *responseArray, NSError *error))completionHandler;

@end
