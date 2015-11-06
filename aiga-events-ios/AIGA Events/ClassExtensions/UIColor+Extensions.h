//
//  UIColor+Extensions.h
//  AIGA Events
//
//  Created by Dennis Birch on 11/6/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extensions)

+ (UIColor *)aig_ColorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;

+ (UIColor *)aig_TableViewBackgroundColor;
+ (UIColor *)aig_EventDateAndLocationTextColor;
+ (UIColor *)aig_EventDescriptionTextColor;
+ (UIColor *)aig_ChapterListSeparatorColor;

+ (UIColor *)aig_LightBlueColor;
+ (UIColor *)aig_DarkBlackColor;
+ (UIColor *)aig_MediumBlackColor;
+ (UIColor *)aig_DarkGrayColor;
+ (UIColor *)aig_MediumGrayColor;
+ (UIColor *)aig_MediumLightGrayColor;
+ (UIColor *)aig_LightGrayColor;
+ (UIColor *)aig_VeryLightGrayColor;
+ (UIColor *)aig_RedColor;

@end
