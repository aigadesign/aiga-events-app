//
//  AIGEvent.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/18/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AIGChapter;

@interface AIGEvent : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * abbrevDescription;
@property (nonatomic, retain) NSNumber *eventBriteID;
@property (nonatomic, retain) NSNumber *eTouchesID;
@property (nonatomic, retain) NSString * registerURL;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSData * mainImageData;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) AIGChapter * chapter;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSSet *tickets;

@property (nonatomic, retain) UIImage *thumbnailImage;

@end
