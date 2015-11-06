//
//  AIGUser.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/18/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AIGChapter;

@interface AIGUser : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *chapters;
@end

@interface AIGUser (CoreDataGeneratedAccessors)

- (void)addChaptersObject:(AIGChapter *)value;
- (void)removeChaptersObject:(AIGChapter *)value;
- (void)addChapters:(NSSet *)values;
- (void)removeChapters:(NSSet *)values;

@end
