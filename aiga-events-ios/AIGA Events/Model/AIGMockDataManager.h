//
//  AIGDataManager.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AIGChapter;

@interface AIGMockDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (AIGMockDataManager *)sharedDataManager;

- (NSArray *)chapterList;

- (NSArray *)loadAllEvents;

@end
