//
//  AIGEvent+Extensions.h
//  AIGA Events
//
//  Created by George McCarroll on 1/7/14.
//  Copyright (c) 2014 Deloitte Digital. All rights reserved.
//

#import "AIGEvent.h"

@class AIGEventLocation;
@class AIGCoreDataManager;

#define kEventEntityName    @"AIGEvent"

@interface AIGEvent (Extensions)

- (AIGEventLocation *)eventLocation;

- (NSString *)eventDateRange;
- (UIImage *)mainImage;
- (NSString *)eventPriceRange;
-(NSString *)trimmedAddress;

+ (NSArray *)eventsForChapter:(AIGChapter *)chapter;
+(NSUInteger)countOfEventsForChapter:(AIGChapter *)chapter;

+ (void)importEventbriteEvents:(NSDictionary *)eventsDict
                    forChapter:(AIGChapter *)chapter
                   dataManager:(AIGCoreDataManager *)coreDataManager
             completionHandler:(void (^)(BOOL hasChanges))completionHandler;

+ (void)importETouchesEvents:(NSArray *)eventsArray forChapter:(AIGChapter *)chapter completionHandler:(void (^)(BOOL hasChanges))completionHandler;

+ (void)purgeOldEvents;


@end
