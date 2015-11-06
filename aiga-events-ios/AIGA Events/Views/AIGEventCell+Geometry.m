
//  AIGEventCell+Geometry.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/23/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventCell+Geometry.h"
#import "AIGEvent+Extensions.h"
#import "AIGChapter.h"
#import "UIFont+AIGAExtensions.h"
#import "NSString+HTML.h"

@implementation AIGEventCell (Geometry)

#define kMaxLabelHeight 999

+ (NSAttributedString *)aig_AttributedStringForTitle:(NSString *)title
{
    if (title == nil) {
        title = @"";
    }
    
    UIFont *titleFont = [UIFont aig_EventTitleFont];
    NSAttributedString *titleAttribString = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: titleFont}];

    return titleAttribString;
}


+ (NSAttributedString *)aig_AttributedStringForDate:(NSString *)dateString
{
    if (dateString == nil) {
        dateString = @"";
    }
    // add a space to get a a more realistic string for determining height
    dateString = [dateString stringByAppendingString:@" "];

    UIFont *dateFont = [UIFont aig_EventDateFont];
    NSAttributedString *dateAttribString = [[NSAttributedString alloc] initWithString:dateString attributes:@{NSFontAttributeName : dateFont}];
    return dateAttribString;
}


+ (NSAttributedString *)aig_AttributedStringForDescription:(NSString *)desc
{
    if (desc == nil) {
        desc = @"";
    }
    UIFont *descriptionFont = [UIFont aig_EventDescriptionFont];
    NSAttributedString *descAttribString = [[NSAttributedString alloc] initWithString:desc attributes:@{NSFontAttributeName : descriptionFont}];
    return descAttribString;
}

+ (NSAttributedString *)aig_AttributedStringForDetailsLabel:(NSString *)text
{
    if (text == nil) {
        text = @"";
    }
    
    UIFont *descriptionFont = [UIFont aig_DetailsLabelFont];
    NSAttributedString *descAttribString = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : descriptionFont}];
    return descAttribString;
}

+ (CGFloat)aig_HeightForAttributedString:(NSAttributedString *)attrString withLineLimit:(NSUInteger)lineLimit
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCellLabelWidth, kMaxLabelHeight)];
    label.numberOfLines = lineLimit;
    label.attributedText = attrString;
    [label sizeToFit];
    
    CGFloat height = label.frame.size.height;
    return height;
}

+ (CGFloat)aig_HeightForTitleLabelWithText:(NSString *)text
{
    // work around a problem with the fact that Interstate-Bold reports itself as having normal weight when set as the font for an attributed string
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCellLabelWidth, kMaxLabelHeight)];
    label.numberOfLines = 3;
    label.text = text;
    label.font = [UIFont aig_EventTitleFont];
    [label sizeToFit];
    
    CGFloat height = label.frame.size.height;
    return height;
}


+ (CGFloat)aig_heightForCellWithEvent:(AIGEvent *)event isInCalendar:(BOOL)isInCalendar
{
    if (event == nil) {
        return 100;
    }
    
    NSString *title = [event.eventTitle uppercaseString];
    NSAttributedString *descript = [AIGEventCell aig_AttributedStringForDescription:event.eventDescription];
    NSString *locString = [self locationLabelTextForEvent:event isInCalendar:isInCalendar];
    NSString *dateRange = event.eventDateRange;
    NSAttributedString *location = (locString.length > dateRange.length) ? [AIGEventCell aig_AttributedStringForDate:locString] : [AIGEventCell aig_AttributedStringForDate:dateRange];
    
    CGFloat result = [AIGEventCell aig_HeightForTitleLabelWithText:title] +
    [AIGEventCell aig_HeightForAttributedString:location withLineLimit:3];

    CGFloat descriptionHeight = 0;
    if (!isInCalendar) {
        descriptionHeight = [AIGEventCell aig_HeightForAttributedString:descript withLineLimit:3];
    }
    result += descriptionHeight;
    
    return result + (kLabelTop * 2) + (kVerticalLabelSpacing * 4);
}

+ (NSString *)locationLabelTextForEvent:(AIGEvent *)event isInCalendar:(BOOL)isInCalendar
{
    NSString *location;
    if (isInCalendar) {
        location = [event.chapter.city uppercaseString];
    } else {
        if (event.venueName == nil) {
            location = @"";
        } else {
            location = [[event.venueName kv_decodeHTMLCharacterEntities] uppercaseString];
        }
    }
    
    location = [location kv_decodeHTMLCharacterEntities];
    return location;
}

- (CGFloat)aig_heightForCell
{
    return self.contentView.bounds.size.height;
}

@end
