//
//  AIGChapter.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/18/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AIGUser;

@interface AIGChapter : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * eventBriteOrg;
@property (nonatomic, retain) NSString * eTouchesID;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) AIGUser *user;
@property (nonatomic, assign) BOOL selected;
@end

@interface AIGChapter (CoreDataGeneratedAccessors)

@end
