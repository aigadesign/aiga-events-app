//
//  UIFont+AIGAExtensions.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/23/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (AIGAExtensions)

+ (UIFont *)aig_EventTitleFont;
+ (UIFont *)aig_EventDateFont;
+ (UIFont *)aig_EventDescriptionFont;
+ (UIFont *)aig_DetailsLabelFont;
+ (UIFont *)aig_ChapterListingFont;
+ (UIFont *)aig_RegularFontOfSize:(NSUInteger)size;
+ (UIFont *)aig_BoldFontOfSize:(NSUInteger)size;

@end
