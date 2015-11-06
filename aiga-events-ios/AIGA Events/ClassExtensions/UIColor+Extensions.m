//
//  UIColor+Extensions.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/6/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+ (UIColor *)aig_ColorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}


+ (UIColor *)aig_TableViewBackgroundColor
{
    return [UIColor aig_VeryLightGrayColor];
}

+ (UIColor *)aig_EventDescriptionTextColor
{
    return [UIColor aig_MediumLightGrayColor];
}


+ (UIColor *)aig_EventDateAndLocationTextColor
{
    return [UIColor aig_MediumGrayColor];
}

+ (UIColor *)aig_ChapterListSeparatorColor
{
    return [UIColor aig_ColorWithRed:226 green:227 blue:228];
}

+ (UIColor *)aig_LightBlueColor
{
    return [UIColor aig_ColorWithRed:57 green:216 blue:226];
}

+ (UIColor *)aig_DarkBlackColor
{
    return [UIColor aig_ColorWithRed:39 green:39 blue:40];
}

+ (UIColor *)aig_MediumBlackColor
{
    return [UIColor aig_ColorWithRed:56 green:56 blue:56];
}


+ (UIColor *)aig_DarkGrayColor
{
    return [UIColor aig_ColorWithRed:82 green:82 blue:82];
}

+ (UIColor *)aig_MediumGrayColor
{
    return [UIColor aig_ColorWithRed:128 green:128 blue:128];
}


+ (UIColor *)aig_MediumLightGrayColor
{
    return [UIColor aig_ColorWithRed:145 green:145 blue:145];
}

+ (UIColor *)aig_LightGrayColor
{
    return [UIColor aig_ColorWithRed:179 green:179 blue:179];
}

+ (UIColor *)aig_VeryLightGrayColor
{
    return [UIColor aig_ColorWithRed:239 green:239 blue:239];
}

+ (UIColor *)aig_RedColor
{
    return [UIColor aig_ColorWithRed:213 green:79 blue:80];
}



@end
