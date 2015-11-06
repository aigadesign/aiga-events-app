//
//  MonthYearView.h
//  Calendar
//
//  Created by Dennis Birch on 8/18/12.
//
//

#import <UIKit/UIKit.h>
@class MonthDateView;

@interface MonthYearView : UIView

@property (nonatomic, assign)MonthDateView *currentMonth;
@property (nonatomic, assign) NSDate *displayedDate;


- (id) initWithDate:(NSDate *)date currentMonth:(MonthDateView *)month frame:(CGRect)frame;

@end
