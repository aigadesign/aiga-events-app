//
//  AIGChapter+Extensions.h
//  AIGA Events
//
//  Created by George McCarroll on 1/7/14.
//  Copyright (c) 2014 Deloitte Digital. All rights reserved.
//

#import "AIGChapter.h"

@class AIGEvent;

#define kChapterEntityName  @"AIGChapter"
#define kEventBriteIDKey    @"eventBriteID"
#define kETouchesIDKey      @"eTouchesID"
#define kParseChapterIDKey  @"City"

@interface AIGChapter (Extensions)

//- (void)addEventsObject:(AIGEvent *)value;
//- (void)removeEventsObject:(AIGEvent *)value;
//- (void)addEvents:(NSSet *)values;
//- (void)removeEvents:(NSSet *)values;

- (NSArray *)eventsForChapter;
-(NSUInteger)countOfEventsForChapter;

- (AIGEvent *)eventWithID:(NSNumber *)eventID;


+ (NSArray *)allChapterNames;
+ (NSArray *)selectedChapters;
+ (NSArray *)sortedChapters;
+ (instancetype)chapterWithCity:(NSString *)city contactName:(NSString *)contact email:(NSString *)email eventBriteID:(NSString *)eventBriteID;
+ (AIGChapter *)chapterForCity:(NSString *)city;
+ (NSArray *)namesForChapters:(NSArray *)chapters;

+ (void)importChapters:(NSDictionary *)chaptersDict;

+(NSDictionary *)chaptersDict;
+(NSArray *)sortedChapterInitials;
@end
