//
//  AIGCoreDataManager.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/18/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AIGChapter;

extern NSString * AIGCoreDataManagerErrorDomain;

//typedef NS_ENUM(NSInteger, AIGCoreDataManagerErrorType) {
//	AIGCoreDataManagerErrorTypeUnknown = 1,
//	AIGCoreDataManagerErrorTypeMissingManagedObjectContext,
//	AIGCoreDataManagerErrorTypeNothingToSave
//};

@interface AIGCoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *privateContext;

// chapters the user has marked to follow
@property (nonatomic, copy) NSArray *userChapterNames;

+ (instancetype)sharedCoreDataManager;

// shared manager for unit tests
+ (instancetype)sharedCoreDataTestManager;

- (void)saveContextAndWait:(BOOL)wait;

-(void)initialize;

-(void)cleanup;
@end
