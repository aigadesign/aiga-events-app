//
//  AIGEventTicket.h
//  AIGA Events
//
//  Created by Dennis Birch on 11/22/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AIGEvent;

@interface AIGEventTicket : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDecimalNumber * cost;
@property (nonatomic, retain) AIGEvent *event;

@end
