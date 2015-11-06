
#import "NSCalendar+Extensions.h"

@implementation NSCalendar (Extensions)

- (void)enumerateFromDate:(NSDate *)startDate toDate:(NSDate *)endDate usingBlock:(void (^)(NSDate *date))block;
{
    NSParameterAssert([[startDate earlierDate:endDate] isEqualToDate:startDate]);
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 1;
    NSDate *date = startDate;
    
    do {
        block(date);
        date = [self dateByAddingComponents:dateComponents toDate:date options:0];
    } while ([[date earlierDate:endDate] isEqualToDate:date]);
}

- (NSDate *)truncatedDate:(NSDate *)date;
{
    NSDateComponents *dateComponents = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    return [self dateFromComponents:dateComponents];
}

- (BOOL)sameMonthDate:(NSDate *)date1 asDate:(NSDate *)date2
{
    NSUInteger yearMonthBits = NSYearCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *date1Components = [self components:yearMonthBits fromDate:date1];
    NSDateComponents *date2Components = [self components:yearMonthBits fromDate:date2];
    return (date1Components.year==date2Components.year && date1Components.month==date2Components.month);
}

- (NSDate *)firstDayOfWeekRelativeToDate:(NSDate *)date;
{
    NSRange weekdayRange = [self rangeOfUnit:NSWeekdayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSDateComponents *dateComponents = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:date];
    dateComponents.weekday = weekdayRange.location;
    return [self dateFromComponents:dateComponents];
}

- (NSDate *)lastDayOfWeekRelativeToDate:(NSDate *)date;
{
    NSRange weekdayRange = [self rangeOfUnit:NSWeekdayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSDateComponents *dateComponents = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:date];
    dateComponents.weekday = weekdayRange.length;
    return [self dateFromComponents:dateComponents];
}

- (NSDate *)firstDayOfMonthRelativeToDate:(NSDate *)date;
{
    NSDateComponents *dateComponents = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    dateComponents.day = 1;
    return [self dateFromComponents:dateComponents];
}

- (NSDate *)lastDayOfMonthRelativeToDate:(NSDate *)date;
{
    NSRange range = [self rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSDateComponents *dateComponents = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    dateComponents.day = NSMaxRange(range) - 1;
    return [self dateFromComponents:dateComponents];
}

- (NSDate *)previousMonthRelativeToDate:(NSDate *)date;
{
    return [self offsetByMonths:-1 relativeToDate:date];
}

- (NSDate *)nextMonthRelativeToDate:(NSDate *)date;
{
    return [self offsetByMonths:1 relativeToDate:date];
}

- (NSDate *)offsetByMonths:(NSInteger)offset relativeToDate:(NSDate *)date;
{
    NSDateComponents *dateComponents = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    dateComponents.month += offset;
    return [self dateFromComponents:dateComponents];
}

@end
