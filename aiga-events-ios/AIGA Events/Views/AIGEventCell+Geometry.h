//
//  AIGEventCell+Geometry.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/23/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventCell.h"

@interface AIGEventCell (Geometry)

+ (NSAttributedString *)aig_AttributedStringForTitle:(NSString *)title;
+ (NSAttributedString *)aig_AttributedStringForDate:(NSString *)date;
+ (NSAttributedString *)aig_AttributedStringForDescription:(NSString *)desc;
+ (NSAttributedString *)aig_AttributedStringForDetailsLabel:(NSString *)text;

+ (CGFloat)aig_HeightForAttributedString:(NSAttributedString *)attrString
                           withLineLimit:(NSUInteger)lineLimit;
+ (CGFloat)aig_heightForCellWithEvent:(AIGEvent *)event isInCalendar:(BOOL)isInCalendar;

- (CGFloat)aig_heightForCell;

@end
