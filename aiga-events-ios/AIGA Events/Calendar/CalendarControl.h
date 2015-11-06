
#import <UIKit/UIKit.h>

@protocol CalendarControlDelegate;

@interface CalendarControl : UIControl


@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSArray *aigEvents;
@property (nonatomic, weak) id <CalendarControlDelegate> delegate;

- (void)showCurrentMonth;
-(void)selectDate:(NSDate *)date;

@end


@protocol CalendarControlDelegate <NSObject>

- (void)calendarControl:(CalendarControl *)calendarControl didSelectDate:(NSDate *)selectedDate;
- (void)monthChangedInCalendarControl:(CalendarControl *)calendarControl;

@end
