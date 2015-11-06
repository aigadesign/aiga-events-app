//
//  MonthDateView.h
//  Calendar
//
//  Created by Dennis Birch on 8/11/12.
//
//

#import <UIKit/UIKit.h>

@interface MonthDateView : UIView

@property (nonatomic, assign) NSCalendar *calendar;
@property (nonatomic, assign) NSDate *selectedDate;
@property (nonatomic, assign) NSDate *displayedDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSArray *eventDates;

@end
