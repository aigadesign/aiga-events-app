

#import "CalendarControl.h"
#import "NSCalendar+Extensions.h"
#import "NSDate+Extensions.h"
#import <QuartzCore/QuartzCore.h>
#import "MonthDateView.h"
#import "MonthYearView.h"
#import "CalendarDefines.h"
#import "AIGEvent+Extensions.h"
#import "NSCalendar+Extensions.h"
#import <QuartzCore/QuartzCore.h>


@interface CalendarControl () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSDate *displayedDate;
@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) MonthDateView *currentMonth;
@property (nonatomic, strong) MonthDateView *lastMonth;
@property (nonatomic, strong) MonthYearView *currentMonthNameYear;
@property (nonatomic, strong) MonthYearView *lastMonthNameYear;

@property (nonatomic, strong) NSArray *eventDates;

@end

@implementation CalendarControl

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder;
{
    if ((self = [super initWithCoder:decoder])) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit;
{
    self.calendar = [NSCalendar currentCalendar];

    self.displayedDate = [self.calendar truncatedDate:[NSDate date]];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handleTap:)];
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleSwipeLeft:)];
    swipeLeft.delegate = self;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleSwipeRight:)];
    swipeRight.delegate = self;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRight];

    self.previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.previousButton setImage:[UIImage imageNamed:@"calender_previous"]
                         forState:UIControlStateNormal];
    self.previousButton.frame = CGRectZero;
    [self addSubview:self.previousButton];
    [self.previousButton addTarget:self action:@selector(showPreviousMonth)
                  forControlEvents:UIControlEventTouchUpInside];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton setImage:[UIImage imageNamed:@"calender_next"]
                     forState:UIControlStateNormal];
    self.nextButton.frame = CGRectZero;
    [self addSubview:self.nextButton];
    [self.nextButton addTarget:self action:@selector(showNextMonth)
              forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setAigEvents:(NSArray *)aigEvents
{
    NSMutableArray *eventDates = [NSMutableArray arrayWithCapacity:aigEvents.count];
    for (AIGEvent *event in aigEvents) {
        NSInteger eventDays = [NSDate daysBetweenDate:event.startTime andDate:event.endTime];
        
        if (eventDays == 0) {
            [eventDates addObject:[self.calendar truncatedDate:event.startTime]];
        }
        else if (eventDays > 0) {
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.day = 1;
            
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *newDate = [self.calendar truncatedDate:event.startTime];
            [eventDates addObject:[self.calendar truncatedDate:event.startTime]];

            for (int i = 0; i < eventDays; i++) {
                newDate = [theCalendar dateByAddingComponents:dayComponent toDate:newDate options:0];
                [eventDates addObject:newDate];
            }
        }
    }
    
    _aigEvents = aigEvents;
    self.eventDates = [eventDates copy];
}

#pragma mark - Event Handling

- (void)showCurrentMonth;
{
    [self showOffsetByMonths:0 relativeToDate:[NSDate date]];
}

- (void)showPreviousMonth;
{
    [self showOffsetByMonths:-1 relativeToDate:self.displayedDate];
}

- (void)showNextMonth;
{
    [self showOffsetByMonths:1 relativeToDate:self.displayedDate];
}

- (void)showOffsetByMonths:(NSInteger)offset relativeToDate:(NSDate *)date
{
    self.displayedDate = [self.calendar offsetByMonths:offset relativeToDate:[self.calendar firstDayOfMonthRelativeToDate:date]];
    self.currentMonth.displayedDate = self.displayedDate;
	
//	// figure out the animation center points
//	CGRect rect = self.frame;
//
//	// only animate the portion between the header and the bottom of the calendar
//	rect.origin.y += kCalendarHeaderHeight;
//	rect.size.height -= kCalendarHeaderHeight;
	
    [self setNeedsDisplay];
        
    [self.delegate monthChangedInCalendarControl:self];

    NSDate *firstDayOfMonth = [self.calendar firstDayOfMonthRelativeToDate:self.displayedDate];
    NSDate *lastDayOfMonth = [self.calendar lastDayOfMonthRelativeToDate:self.displayedDate];

    if ([self.selectedDate compare:firstDayOfMonth] != NSOrderedAscending &&
        [self.selectedDate compare:lastDayOfMonth] != NSOrderedDescending)
    {
        //the currently selected date is in the displayed month
        [self.delegate calendarControl:self didSelectDate:self.selectedDate];
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint point = [touch locationInView:self];
        
        if (point.y < kCalendarHeaderHeight) {
            return NO;
        }
    }
    else if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
    {
        CGPoint point = [touch locationInView:self.currentMonth];
        
        if (!CGRectContainsPoint(self.currentMonth.frame, point)) {
            return NO;
        }
    }
    
    return YES;
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [self.currentMonth sizeThatFits:self.frame.size];
    size.height += kCalendarHeaderHeight + kCalendarTileHeight;
    return size;
}

-(void)selectDate:(NSDate *)date
{
    self.selectedDate = date;
    self.displayedDate = self.selectedDate;
    
    [self setNeedsDisplay];
    [self.delegate calendarControl:self didSelectDate:self.selectedDate];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer;
{
    CGPoint point = [tapGestureRecognizer locationInView:self];
    point = [self convertPoint:point toView:self.currentMonth];

    NSDateComponents *currentDateComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.displayedDate];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = currentDateComponents.year;
    dateComponents.month = currentDateComponents.month;
    dateComponents.weekOfMonth = floorf(point.y / kCalendarTileHeight);
    // handle user tapping extreme edges of row
    NSInteger weekday = floorf((point.x + kCalendarTileWidth)/ kCalendarTileWidth);
    dateComponents.weekday = (weekday > 7) ? 7 : (weekday < 1) ? 1 : weekday;
    
    self.selectedDate = [self.calendar dateFromComponents:dateComponents];

    NSDateComponents *oldDisplayedComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self.displayedDate];
    NSDateComponents *newDisplayedComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self.selectedDate];
        //newDateComponents is not the same as dateComponents, due to weekOfMonth+weekday adjustments
    BOOL monthChanged = (oldDisplayedComponents.month != newDisplayedComponents.month ||
                         oldDisplayedComponents.year != newDisplayedComponents.year);
    
    self.displayedDate = self.selectedDate;
    if (monthChanged) {
        self.currentMonth.displayedDate = self.displayedDate;
    }
    [self setNeedsDisplay];
    if (monthChanged) {
        [self.delegate monthChangedInCalendarControl:self];
    }

    [self.delegate calendarControl:self didSelectDate:self.selectedDate];
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self showNextMonth];
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self showPreviousMonth];
}

#pragma mark - Layout

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGFloat buttonTop = 0.0;

    self.previousButton.frame = CGRectMake(self.frame.origin.x,
                                           buttonTop,
                                           kCalendarHeaderHeight + 20,
                                           kCalendarHeaderHeight);
    CGFloat nextX = self.frame.size.width - kCalendarHeaderHeight - 20;
    self.nextButton.frame = CGRectMake(nextX,
                                       buttonTop,
                                       kCalendarHeaderHeight + 20,
                                       kCalendarHeaderHeight);
}

- (CGSize)sizeThatFits:(CGSize)size;
{
	NSInteger lastWeek = [self.calendar components:NSWeekOfMonthCalendarUnit fromDate:[self.calendar lastDayOfMonthRelativeToDate:self.displayedDate]].weekOfMonth;
    
    CGSize newSize = CGSizeZero;
    newSize.width = (kCalendarTileWidth + kCalendarTileSpacing) * 7;
    newSize.height = (kCalendarTileHeight + kCalendarTileSpacing) * (lastWeek + 1);
    
    return newSize;
}


- (void)drawRect:(CGRect)rect
{
	float width = [self sizeThatFits:rect.size].width;
    
    self.backgroundColor = [UIColor whiteColor];
	
    // adjust the drawing rect left origin
    CGFloat delta = (rect.size.width - width)/2;
    rect.origin.x += delta;
    rect.size.width = width;
    
	// draw the header gradient area
	CGRect monthRect = CGRectMake(rect.origin.x, kCalendarHeaderHeight, width, rect.size.height - kCalendarHeaderHeight);
	
	[self.lastMonth removeFromSuperview];
	[self.lastMonthNameYear removeFromSuperview];
	[self setLastMonth:nil];
	[self setLastMonthNameYear:nil];
	
	self.currentMonth = [[MonthDateView alloc]initWithFrame:monthRect];
	self.currentMonth.calendar = self.calendar;
    self.currentMonth.eventDates = self.eventDates;
	self.currentMonth.displayedDate = self.displayedDate;
	self.currentMonth.selectedDate = self.selectedDate;
	[self addSubview:self.currentMonth];
	self.lastMonth = self.currentMonth;
		
	// display Month/Year
    CGRect hFrame = rect;
    hFrame.size.height = kCalendarHeaderHeight;
	self.currentMonthNameYear = [[MonthYearView alloc] initWithDate:self.displayedDate currentMonth:self.currentMonth frame:hFrame];
	[self addSubview:self.currentMonthNameYear];
	[self sendSubviewToBack:self.currentMonthNameYear];
	self.lastMonthNameYear = self.currentMonthNameYear;
}

@end
