//
//  MonthDateView.m
//  Calendar
//
//  Created by Dennis Birch on 8/11/12.
//
//

#import "MonthDateView.h"
#import "NSCalendar+Extensions.h"
#import "CalendarDefines.h"
#import "CalendarDefines.h"
#import "UIColor+Extensions.h"
#import "NSDate+Extensions.h"

@interface MonthDateView ()

@property (nonatomic, strong) NSDateFormatter *weekdayNameFormatter;
@property (nonatomic, strong) NSDateFormatter *dateNumberFormatter;

@end

@implementation MonthDateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.dateFormatter = [[NSDateFormatter alloc] init];
		[self.dateFormatter setDateFormat:@"MMMM YYYY"];
		
		self.weekdayNameFormatter = [[NSDateFormatter alloc] init];
		[self.weekdayNameFormatter setDateFormat:@"EEE"];
        
        self.dateNumberFormatter = [[NSDateFormatter alloc] init];
		[self.dateNumberFormatter setDateFormat:@"d"];
    }
    return self;
}


void drawGridlines(CGContextRef context, CGRect rect)
{
	float width = rect.size.width;
	float height = rect.size.height;
	
	CGContextSaveGState(context);
	
	// line drawing begins here
	CGColorRef lineColor = [UIColor aig_ColorWithRed:241 green:242 blue:242].CGColor;
	
	CGContextSetLineWidth(context, .5);
	
	// stroke a single dark gray line at the bottom of the header
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, width, 0);
	CGContextSetStrokeColorWithColor(context, lineColor);
	CGContextStrokePath(context);
		
	float topPos = kCalendarHeaderHeight + kCalendarTileSpacing;
	
	// draw the horizontal lines
	topPos = kCalendarTileSpacing;
	while (topPos < height - kCalendarTileHeight) {
		topPos += kCalendarTileHeight;
		CGContextMoveToPoint(context, 0, topPos);
		CGContextAddLineToPoint(context, width, topPos);
		CGContextSetStrokeColorWithColor(context, lineColor);
		CGContextStrokePath(context);
		
		topPos += 1;
	}
    
    CGContextRestoreGState(context);
}



- (void)drawBackgroundGrid:(CGContextRef)context rect:(CGRect)rect
{
	// fill the background with color
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextBeginPath(context);
	CGContextFillRect(context, rect);
	
	CGContextSaveGState(context);
	
	// draw gridlines
    CGRect sizeRect = rect;
    CGSize drawSize = [self sizeThatFits:sizeRect.size];
    sizeRect.size = drawSize;
	drawGridlines(context, sizeRect);
}

- (CGSize)sizeThatFits:(CGSize)size;
{
	NSInteger lastWeek = [self.calendar components:NSWeekOfMonthCalendarUnit fromDate:[self.calendar lastDayOfMonthRelativeToDate:self.displayedDate]].weekOfMonth;
    
    CGSize newSize = CGSizeZero;
    newSize.width = (kCalendarTileWidth + kCalendarTileSpacing) * 7;
    newSize.height = (kCalendarTileHeight + kCalendarTileSpacing) * lastWeek;
    return newSize;
}



- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	[self drawBackgroundGrid:context rect:rect];
    
    if (self.calendar == nil) {
        return;
    }
    
    NSMutableArray *weekdayAbbrev;
    weekdayAbbrev = [self.weekdayNameFormatter.shortWeekdaySymbols mutableCopy];
    for (int i = 0; i < weekdayAbbrev.count; i++) {
        weekdayAbbrev[i] = [weekdayAbbrev[i] uppercaseString];
    }
    
	__block BOOL isSelectedDate = NO;
	__block BOOL isToday = NO;
    __block BOOL hasAIGAEvent = NO;
	
    NSInteger firstWeek = [self.calendar components:NSWeekOfMonthCalendarUnit
                                           fromDate:[self.calendar firstDayOfMonthRelativeToDate:self.displayedDate]].weekOfMonth;
    NSInteger lastWeek = [self.calendar components:NSWeekOfMonthCalendarUnit
                                          fromDate:[self.calendar lastDayOfMonthRelativeToDate:self.displayedDate]].weekOfMonth;
	
    NSDate *firstDayOfMonth = [self.calendar firstDayOfMonthRelativeToDate:self.displayedDate];
    NSDate *lastDayOfMonth = [self.calendar lastDayOfMonthRelativeToDate:self.displayedDate];
    
    NSDate *startDate = [self.calendar firstDayOfWeekRelativeToDate:firstDayOfMonth];
    NSDate *endDate = [self.calendar lastDayOfWeekRelativeToDate:lastDayOfMonth];
    
	UIColor *selectedDayBGColor = [UIColor aig_DarkGrayColor];
    UIColor *normalDayColor = [UIColor aig_MediumGrayColor];
    UIColor *notInMonthDayColor = [UIColor aig_LightGrayColor];
    UIColor *eventDayColor = [UIColor aig_LightBlueColor];
    UIColor *todayColor = [UIColor aig_RedColor];
    
    /*
     date from previous month R 179 G 179 B 179
     Selected date  Background R 82 G 82 B 82 with type in R255 G 255 B 255
     Today's date with R 213 G 79 B 80
     Event date with R 57 G 216 B 226
     All other dates with R 128 G 128 B 128
     
     Current date is red
     Selecting current date with event highlights date with blue, red if it's today
     
     */
    
    __block UIColor *dateStringDrawingColor;
    
    [self.calendar enumerateFromDate:startDate toDate:endDate usingBlock:^(NSDate *date) {
        NSDateComponents *dateComponents = [self.calendar components:NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit fromDate:date];
		
		CGContextSaveGState(context);
		
		isSelectedDate = NO;
		
        // This variable tells you which day of the week "date" falls on
        // Sunday = 1 and Saturday = 7
        NSInteger weekday = dateComponents.weekday;
		
        // This variable tells you which week of the month "date" is within
        NSInteger week = dateComponents.weekOfMonth;
        
        BOOL isBeforeMonth = NO;
        BOOL isAfterMonth = NO;
		
        if ([lastDayOfMonth compare:date] == NSOrderedAscending) {
            week = lastWeek;
            isBeforeMonth = YES;
        } else if ([firstDayOfMonth compare:date] == NSOrderedDescending) {
            week = firstWeek;
            isAfterMonth = YES;
        }
		
		CGRect dayRect = CGRectMake((weekday - 1) * (kCalendarTileWidth + kCalendarTileSpacing) + 1,
									week * (kCalendarTileHeight + kCalendarTileSpacing),
									kCalendarTileWidth,
									kCalendarTileHeight);
		
		// draw day name abbreviation
		if (week == 1) {
            CGContextSaveGState(context);
            
            CGRect weekDaysRect = dayRect;
            weekDaysRect.origin.y -= kCalendarTileHeight;
            
            NSString *dayString = weekdayAbbrev[weekday - 1];
            UIFont *dayNameFont = [UIFont fontWithName:@"Interstate-Light" size:10.5];
            CGSize size = [dayString sizeWithAttributes:@{NSFontAttributeName : dayNameFont}];
            
            CGPoint drawPoint;
            drawPoint.x = weekDaysRect.origin.x + (kCalendarTileWidth - size.width)/2;
            drawPoint.y	= weekDaysRect.origin.y + (kCalendarTileHeight - size.height)/2;
            
            NSMutableParagraphStyle *graphStyle = [[NSMutableParagraphStyle alloc] init];
            UIColor *fontColor = normalDayColor;
            graphStyle.alignment = NSTextAlignmentCenter;
            [dayString drawAtPoint:drawPoint withAttributes:@{NSFontAttributeName : dayNameFont,
                                                              NSParagraphStyleAttributeName : graphStyle,
                                                              NSForegroundColorAttributeName : fontColor}];
            
            CGContextRestoreGState(context);
		}
        
        // reinitialize for each pass through
		isToday = NO;
        isSelectedDate = NO;
        hasAIGAEvent = NO;
        
		// draw the dark rectangle for the selected date
		if (self.selectedDate != nil &&
            [[self.calendar truncatedDate:date] compare:[self.calendar truncatedDate:self.selectedDate]] == NSOrderedSame &&
            [self.calendar sameMonthDate:self.selectedDate asDate:self.displayedDate]) {
            isSelectedDate = YES;
        }
        
        NSDate *today = [NSDate date];
        NSDateComponents *todayComponents = [self.calendar components:NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit fromDate:today];
        
        CGContextSaveGState(context);
        if (todayComponents.month == dateComponents.month && todayComponents.year == dateComponents.year && todayComponents.day == dateComponents.day) {
            isToday = YES;
        }
        
        if (isSelectedDate) {
            CGContextSetFillColorWithColor(context, selectedDayBGColor.CGColor);
            CGContextFillRect(context, dayRect);
            CGContextRestoreGState(context);
            
            dateStringDrawingColor = [UIColor whiteColor];
            
        }
        
        dateStringDrawingColor = normalDayColor;
        
        if (isToday) {
            // draw a red underline
            CGContextSetStrokeColorWithColor(context, todayColor.CGColor);
            CGFloat height = dayRect.size.height - 1.0;
            CGRect todayRect = dayRect;
            todayRect.origin.y += height;
            todayRect.size.height -= height;
            CGContextStrokeRect(context, todayRect);
        }
        
        hasAIGAEvent = ([self.eventDates indexOfObject:[self.calendar truncatedDate:date]] != NSNotFound);
        
        if (isBeforeMonth || isAfterMonth) {
            dateStringDrawingColor = notInMonthDayColor;

        } else {
            if (isSelectedDate) {
                dateStringDrawingColor = [UIColor whiteColor];
            }
            
            if (hasAIGAEvent) {
                dateStringDrawingColor = eventDayColor;
            }
        }
        
        
        // draw the date text
        NSString *dayString = [self.dateNumberFormatter stringFromDate:date];
        UIFont *drawFont = [UIFont fontWithName:@"Interstate-Light" size:14];
        CGSize size = [dayString sizeWithAttributes:@{NSFontAttributeName : drawFont}];
        CGPoint drawPoint;
        drawPoint.x = dayRect.origin.x + (kCalendarTileWidth - size.width)/2;
        drawPoint.y	= dayRect.origin.y + (kCalendarTileHeight - size.height)/2;
        
        NSMutableParagraphStyle *graphStyle = [[NSMutableParagraphStyle alloc] init];
        graphStyle.alignment = NSTextAlignmentCenter;
        [dayString drawAtPoint:drawPoint withAttributes:@{NSFontAttributeName : drawFont,
                                                          NSParagraphStyleAttributeName : graphStyle,
                                                          NSForegroundColorAttributeName : dateStringDrawingColor}];
        
        CGContextRestoreGState(context);
    }];
	
}

@end
