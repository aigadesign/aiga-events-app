//
//  NSDate+Extensions.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

+ (NSDate *)aig_DateWithYear:(NSInteger)year month:(NSInteger)month date:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSDateComponents *components = [NSDate aig_DateCalculationComponents];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    components.year = year;
    components.month = month;
    components.day = day;
    components.hour = hour;
    components.minute = minute;
    
    return [calendar dateFromComponents:components];
}

+ (NSDateComponents *)aig_DateCalculationComponents
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
    
    return components;
}

- (NSDateFormatter *)aig_LongDateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterLongStyle;
    });
    
    return formatter;
}

- (NSDateFormatter *)aig_ShortDateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"M/d/yy";
    });
    
    return formatter;
}


- (NSDateFormatter *)aig_TimeFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeStyle = NSDateFormatterShortStyle;
    });
    
    return formatter;
}

- (NSString *)aig_LongFormattedDate
{
    return [[self aig_LongDateFormatter] stringFromDate:self];
}


- (NSString *)aig_FormattedTime
{
    return [[self aig_TimeFormatter] stringFromDate:self];
}

- (NSString *)aig_LongFormattedDateTime
{
    return [NSString stringWithFormat:@"%@, %@", [self aig_LongFormattedDate], [self aig_FormattedTime]];
}

- (NSString *)aig_ShortFormattedDate
{
    return [[self aig_ShortDateFormatter] stringFromDate:self];
}


- (BOOL)aig_IsSameDay:(NSDate *)otherDate;
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];
    NSDateComponents *otherComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:otherDate];
    
    return components.year == otherComponents.year && components.month == otherComponents.month && components.day == otherComponents.day;
}

+ (NSDate *)aig_EventBriteDateWithString:(NSString *)dateString
{
    // 2013-12-05 11:45:00
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-d HH:mm:ss";
    });
    
    return [dateFormatter dateFromString:dateString];
}

- (NSString *)aig_ETouchesDateString
{
    // 2013-12-05
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
    });
    
    return [dateFormatter stringFromDate:self];
}

- (NSDate *)aig_TruncatedDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self];
    
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
    	return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
    	return NO;
    
    return YES;
}

@end
