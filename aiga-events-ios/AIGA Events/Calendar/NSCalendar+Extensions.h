
#import <Foundation/Foundation.h>

@interface NSCalendar (Extensions)

- (void)enumerateFromDate:(NSDate *)startDate toDate:(NSDate *)endDate usingBlock:(void (^)(NSDate *date))block;

- (NSDate *)truncatedDate:(NSDate *)date;
- (BOOL)sameMonthDate:(NSDate *)date1 asDate:(NSDate *)date2;

- (NSDate *)firstDayOfWeekRelativeToDate:(NSDate *)date;
- (NSDate *)lastDayOfWeekRelativeToDate:(NSDate *)date;

- (NSDate *)firstDayOfMonthRelativeToDate:(NSDate *)date;
- (NSDate *)lastDayOfMonthRelativeToDate:(NSDate *)date;

- (NSDate *)previousMonthRelativeToDate:(NSDate *)date;
- (NSDate *)nextMonthRelativeToDate:(NSDate *)date;
- (NSDate *)offsetByMonths:(NSInteger)offset relativeToDate:(NSDate *)date;

@end
