//
//  MonthYearView.m
//  Calendar
//
//  Created by Dennis Birch on 8/18/12.
//
//

#import "MonthYearView.h"
#import "MonthDateView.h"
#import "UIColor+Extensions.h"
#import "CalendarDefines.h"

@implementation MonthYearView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithDate:(NSDate *)date currentMonth:(MonthDateView *)month frame:(CGRect)frame
{
	if (self = [self initWithFrame:frame]) {
		self.currentMonth = month;
		self.displayedDate = date;
		self.opaque = NO;
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
	NSString *monthYear = [[self.currentMonth.dateFormatter stringFromDate:self.displayedDate] uppercaseString];
    UIColor *fontColor = [UIColor aig_DarkGrayColor];
	UIFont *myFont = [UIFont fontWithName:@"Interstate-Light" size:12];
	CGSize mySize = [monthYear sizeWithAttributes:@{NSFontAttributeName : myFont}];
	CGPoint myPoint = CGPointMake((self.frame.size.width - mySize.width)/2, ((self.frame.size.height - mySize.height+ kCalendarHeaderYOffset)/2) - 6);
    [monthYear drawAtPoint:myPoint withAttributes:@{NSFontAttributeName : myFont,
                                                    NSForegroundColorAttributeName : fontColor}];
}


@end
