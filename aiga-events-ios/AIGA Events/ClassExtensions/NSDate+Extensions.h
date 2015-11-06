//
//  NSDate+Extensions.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

+ (NSDate *)aig_DateWithYear:(NSInteger)year month:(NSInteger)month date:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;

+ (NSDate *)aig_EventBriteDateWithString:(NSString *)dateString;


- (NSString *)aig_LongFormattedDate;

- (NSString *)aig_FormattedTime;

- (NSString *)aig_ETouchesDateString;

- (NSString *)aig_LongFormattedDateTime;

- (NSString *)aig_ShortFormattedDate;

- (BOOL)aig_IsSameDay:(NSDate *)otherDate;

- (NSDate *)aig_TruncatedDate;

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

@end
