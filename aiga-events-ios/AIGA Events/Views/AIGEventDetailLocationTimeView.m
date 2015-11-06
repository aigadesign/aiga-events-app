//
//  AIGEventDetailLocationTimeView.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/14/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventDetailLocationTimeView.h"
#import "AIGEvent+Extensions.h"
#import "UIColor+Extensions.h"
#import "UIFont+AIGAExtensions.h"
#import "NSString+HTML.h"
@import MapKit;

@interface AIGEventDetailLocationTimeView ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *venueLabel;
@property (nonatomic, strong) UILabel *locationHeadingLabel;
@property (nonatomic, strong) UILabel *dateTimeHeadingLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) UIView *ticketView;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UIImageView *mapArrow;
@property (nonatomic, strong) UIImageView *registerArrow;
@property (nonatomic, strong) UIImageView *verticalSeparator;

@property (nonatomic, strong) UIButton *mapButton;
@property (nonatomic, strong) UIButton *calendarButton;

@end

@implementation AIGEventDetailLocationTimeView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor aig_TableViewBackgroundColor];
        // allow shadow below
        self.layer.masksToBounds = NO;
    }
    return self;
}

- (void)setCurrentEvent:(AIGEvent *)currentEvent
{
    _currentEvent = currentEvent;

    UIImageView *arrow;
    
    if (self.registerArrow == nil) {
        arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow"]];
        arrow.userInteractionEnabled = YES;
        [arrow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerButtonTapped)]];
        self.registerArrow = arrow;
    }
    
    // add dark gray ticket view at top
    CGRect ticketFrame = CGRectMake(12.0, 24.0, 148.0, 12.0);
    NSAttributedString *attributedButtonString;

    if (self.ticketView == nil) {
        UIView *ticketView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40.0)];
        ticketView.backgroundColor = [UIColor aig_DarkGrayColor];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:ticketFrame];
        
        CGPoint center = ticketView.center;
        center.y -= priceLabel.bounds.size.height / 2;
        
        priceLabel.frame = CGRectMake(priceLabel.frame.origin.x, center.y, priceLabel.bounds.size.width, priceLabel.bounds.size.height);
        priceLabel.textColor = [UIColor whiteColor];
        priceLabel.backgroundColor = [UIColor clearColor];
         self.priceLabel = priceLabel;
        [ticketView addSubview:self.priceLabel];
        
        // add arrow
        ticketFrame.origin.x = self.bounds.size.width - arrow.bounds.size.width - 12.0;
        ticketFrame.origin.y = self.priceLabel.frame.origin.y;
        ticketFrame.size.width = arrow.frame.size.width;
        ticketFrame.size.height = arrow.frame.size.height;
        arrow.frame = ticketFrame;
        [ticketView addSubview:arrow];
        
        // add GET TICKETS button
        if (self.currentEvent.registerURL) {
            UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
            attributedButtonString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"GET TICKETS", nil)
                                                                     attributes:@{NSFontAttributeName : [UIFont aig_RegularFontOfSize:10]}];
            [registerButton setAttributedTitle:attributedButtonString forState:UIControlStateNormal];
            [registerButton sizeToFit];
            ticketFrame = registerButton.frame;
            
            ticketFrame.origin.x = arrow.frame.origin.x - registerButton.bounds.size.width - 4.0;
            ticketFrame.origin.y = arrow.frame.origin.y - 3.0;
            registerButton.frame = ticketFrame;
            [registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            [ticketView addSubview:registerButton];
        }
        
        self.priceLabel.text = [self.currentEvent eventPriceRange];
        
        [self addSubview:ticketView];
        self.ticketView = ticketView;
    }
    
    self.priceLabel.font = [UIFont aig_DetailsLabelFont];

    CGFloat left = 26.0;
    CGFloat width = 160.0;
    CGFloat top = 0.0;
    CGFloat headingToLabelSpacing = 4.0;
    
    width -= left;
    
    if (self.titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.ticketView.frame.size.height + 12.0, 280.0, 34.0)];
        self.titleLabel.textColor = [UIColor aig_MediumBlackColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSString *title = [[self.currentEvent.eventTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];
    }

    self.titleLabel.font = [UIFont aig_EventTitleFont];
    [self.titleLabel sizeToFit];

    CGRect frame;
    
    // vertical separator
    if (self.verticalSeparator == nil) {
        top = self.titleLabel.frame.origin.y + self.titleLabel.bounds.size.height + 12.0;
        UIImageView *verticalSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vertical-line"]];
        frame = verticalSeparator.frame;
        frame.origin = CGPointMake(160.0, top);
        frame.size.height = 50.0;
        verticalSeparator.frame = frame;
        [self addSubview:verticalSeparator];
        self.verticalSeparator = verticalSeparator;
    }

    // left half setup
    CGFloat maxDepth = 0;
    UIImageView *iconView;
    CGPoint iconOrigin;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 1.5f;
    
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle};

    if (self.mapButton == nil) {
        top += 6.0;
        iconView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"map_small"]];
        iconOrigin = CGPointMake(16.0, top);
        frame = iconView.frame;
        frame.origin = iconOrigin;
        iconView.frame = frame;
        [self addSubview:iconView];
        
        frame = CGRectMake(frame.size.width + iconOrigin.x + 4.0, top + 4.0, width, 16.0);
        
        self.locationHeadingLabel = [[UILabel alloc] initWithFrame:frame];
        self.locationHeadingLabel.font = [UIFont aig_RegularFontOfSize:14];
        self.locationHeadingLabel.textColor = [UIColor aig_MediumGrayColor];
        self.locationHeadingLabel.text = NSLocalizedString(@"LOCATION", nil);
        [self.locationHeadingLabel sizeToFit];
        [self addSubview:self.locationHeadingLabel];
        
        frame = self.locationHeadingLabel.frame;
        frame.origin.y += frame.size.height + headingToLabelSpacing;
        frame.size.width = 120.0;
        frame.size.height = 40.0;
        self.venueLabel = [[UILabel alloc] initWithFrame:frame];
        self.venueLabel.textColor = [UIColor aig_MediumGrayColor];
        self.venueLabel.numberOfLines = 0;
        [self addSubview:self.venueLabel];
        
        NSString *venue = @"";
        if (self.currentEvent.venueName.length > 0) {
            venue = [venue stringByAppendingString:[self.currentEvent.venueName kv_decodeHTMLCharacterEntities]];
        }
        if (venue.length > 0 && self.currentEvent.address.length > 0) {
            venue = [venue stringByAppendingString:@"\n"];
        }
        if (self.currentEvent.address.length > 0) {
            venue = [venue stringByAppendingString:[[self.currentEvent trimmedAddress] kv_decodeHTMLCharacterEntities]];
        }
        
        self.venueLabel.attributedText = [[NSAttributedString alloc] initWithString:venue attributes:attributes];

        UIButton *mapButton;
        
        // Map button
        mapButton = [UIButton buttonWithType:UIButtonTypeSystem];
        frame = CGRectMake(90.0, maxDepth, 80.0, 40.0);
        mapButton.frame = frame;
        mapButton.contentEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        attributedButtonString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"MAP IT", nil)
                                                                 attributes:@{NSFontAttributeName : [UIFont aig_RegularFontOfSize:10]}];
        [mapButton setAttributedTitle:attributedButtonString forState:UIControlStateNormal];
        [mapButton sizeToFit];
        
        [mapButton addTarget:self action:@selector(mapButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mapButton];
        
        // arrow
        arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow"]];
        arrow.userInteractionEnabled = YES;
        [arrow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapButtonTouched)]];
        frame.origin.x += mapButton.bounds.size.width - 6.0;
        frame.origin.y += 7.0;
        frame.size.width = arrow.frame.size.width;
        frame.size.height = arrow.frame.size.height;
        arrow.frame = frame;
        self.mapArrow = arrow;
        [self addSubview:arrow];
        
        BOOL hasCoordinates = self.currentEvent.longitude.floatValue != 0 && self.currentEvent.latitude.floatValue != 0;
        BOOL hasAddress = self.currentEvent.address.length>0;
        mapButton.hidden = arrow.hidden = !hasCoordinates;
        self.mapButton = mapButton;

        if (hasAddress && !hasCoordinates)
        {
            //Fire up the geocoder so we have coordinates to display on our map
            NSString *geoAddress = self.currentEvent.address;
            __weak __typeof(self) weakSelf = self;
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:geoAddress
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             if (!error) {
                                 //If it succeeded, grab the lat/lon
                                 CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                                 weakSelf.currentEvent.longitude = @(geocodedPlacemark.location.coordinate.longitude);
                                 weakSelf.currentEvent.latitude = @(geocodedPlacemark.location.coordinate.latitude);
                                 mapButton.hidden = arrow.hidden = NO;  //We have our map coordinates now
                             }
                         }];
        }
    }

    self.venueLabel.font = [UIFont aig_DetailsLabelFont];
    [self.venueLabel sizeToFit];
    maxDepth = self.venueLabel.frame.origin.y + self.venueLabel.bounds.size.height;
    

    // right half setup
    if (self.calendarButton == nil) {
        iconView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"calender_small"]];
        iconOrigin = CGPointMake(176.0, top);
        frame = iconView.frame;
        frame.origin = iconOrigin;
        iconView.frame = frame;
        [self addSubview:iconView];
        
        frame = CGRectMake(frame.size.width + iconOrigin.x + 4.0, top + 4.0, width, 16.0);
        
        self.dateTimeHeadingLabel = [[UILabel alloc] initWithFrame:frame];
        self.dateTimeHeadingLabel.font = [UIFont aig_RegularFontOfSize:14];
        self.dateTimeHeadingLabel.textColor = [UIColor aig_MediumGrayColor];
        self.dateTimeHeadingLabel.text = NSLocalizedString(@"DATE & TIME", nil);
        [self.dateTimeHeadingLabel sizeToFit];
        [self addSubview:self.dateTimeHeadingLabel];
        
        frame = self.dateTimeHeadingLabel.frame;
        frame.origin.y += frame.size.height + headingToLabelSpacing;
        frame.size.width = 124.0;
        frame.size.height = 60.0;
        self.dateLabel = [[UILabel alloc] initWithFrame:frame];
        self.dateLabel.textColor = [UIColor aig_MediumGrayColor];
        self.dateLabel.numberOfLines = 0;
        
        NSString *dateText = [self.currentEvent eventDateRange];
        NSRange range = [dateText rangeOfString:@","];
        NSString *date = @"";
        if (range.location <= dateText.length) {
            date = [dateText substringToIndex:range.location];
            NSString *time = [[dateText substringFromIndex:range.location + 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dateText = [NSString stringWithFormat:@"%@\n%@", date, time];
        }
        
        self.dateLabel.text = dateText;
        [self addSubview:self.dateLabel];
        
        //  calendar button
        UIButton *addToCalendarButton = [UIButton buttonWithType:UIButtonTypeSystem];
        frame = CGRectMake(260.0, maxDepth, 80.0, 40.0);
        addToCalendarButton.frame = frame;
        addToCalendarButton.contentEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        attributedButtonString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ADD", nil)
                                                                 attributes:@{NSFontAttributeName : [UIFont aig_RegularFontOfSize:10]}];
        [addToCalendarButton setAttributedTitle:attributedButtonString forState:UIControlStateNormal];
        [addToCalendarButton sizeToFit];
        [addToCalendarButton addTarget:self action:@selector(calendarButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addToCalendarButton];
        
        // arrow
        arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow"]];
        arrow.userInteractionEnabled = YES;
        [arrow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(calendarButtonTapped)]];
        frame.origin.x += addToCalendarButton.bounds.size.width - 6.0; // give it a net offset of 4.0 from button right edge
        frame.origin.y += 7.0;
        frame.size.width = arrow.frame.size.width;
        frame.size.height = arrow.frame.size.height;
        arrow.frame = frame;
        [self addSubview:arrow];
        
        self.calendarButton = addToCalendarButton;

        self.dateLabel.font = [UIFont aig_DetailsLabelFont];
        [self.dateLabel sizeToFit];
        CGFloat dateLabelDepth = self.dateLabel.frame.origin.y + self.dateLabel.bounds.size.height;
        maxDepth = MAX(maxDepth, dateLabelDepth);

        // adjust map button/arrow if necessary
        CGRect tempFrame = self.mapButton.frame;
        tempFrame.origin.y = maxDepth;
        self.mapButton.frame = tempFrame;
        tempFrame = self.mapArrow.frame;
        tempFrame.origin.y = maxDepth + 7;
        self.mapArrow.frame = tempFrame;
        
        tempFrame = self.calendarButton.frame;
        tempFrame.origin.y = maxDepth;
        self.calendarButton.frame = tempFrame;
        tempFrame = arrow.frame;
        tempFrame.origin.y = maxDepth + 7;
        arrow.frame = tempFrame;
    }
 
    

    // horizontal line
    if (self.bottomLine == nil) {
        UIImage *hLine = [[UIImage imageNamed:@"vertical-line"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImageView *hLineView = [[UIImageView alloc] initWithImage:hLine];
        CGFloat hMargin = 20.0;
        CGFloat x = self.bounds.size.width - (hMargin * 2);
        CGFloat y = MAX(self.calendarButton.frame.origin.y, maxDepth);
        hLineView.frame = CGRectMake(hMargin, y + self.calendarButton.bounds.size.height, x, 1.0);
        [self addSubview:hLineView];
        self.bottomLine = hLineView;
    }
 }

- (void)mapButtonTouched
{
    [self.delegate mapButtonTouched];
}

- (void)calendarButtonTapped
{
    [self.delegate calendarButtonTapped];
}

- (void)registerButtonTapped
{
    [self.delegate registerButtonTapped];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = self.superview.bounds.size.width;
    CGFloat height = self.bottomLine.frame.origin.y + 2.0;
    
    return CGSizeMake(width, height);
}

@end
