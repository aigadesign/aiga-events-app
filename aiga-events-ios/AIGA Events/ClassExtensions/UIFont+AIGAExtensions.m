//
//  UIFont+AIGAExtensions.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/23/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "UIFont+AIGAExtensions.h"

@implementation UIFont (AIGAExtensions)

+ (UIFont *)aig_EventTitleFont
{
    UIFont *font = [UIFont fontWithName:@"Interstate-Bold" size: [self aig_preferredSizeForDesignSize:18]];
    return font;
}


+ (UIFont *)aig_EventDateFont
{
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute : @"Interstate"}];
    UIFont *font = [UIFont fontWithDescriptor: fontDescriptor size: [self aig_preferredSizeForDesignSize:9]];
    return font;
}


+ (UIFont *)aig_EventDescriptionFont
{
    // this implementation returns a valid font, to work around an apparent bug in iOS 8.0.2
    // with fontDescriptorWithSymbolicTraits: UIFontDescriptorTraitItalic returning nil    
    NSString *fontFamily = @"Georgia";
    CGFloat fontSize = 12.5;
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                        @{
                                          @"NSFontFamilyAttribute" : fontFamily,
                                          @"NSFontFaceAttribute" : @"Italic"
                                          }];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
    return font;
}

+ (UIFont *)aig_DetailsLabelFont
{
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute : @"Interstate"}];
    UIFont *font = [UIFont fontWithDescriptor: fontDescriptor size: [self aig_preferredSizeForDesignSize:11.5]];
    return font;
}

+ (UIFont *)aig_ChapterListingFont
{
    UIFontDescriptor *normalFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    NSNumber *bodyFontSize = normalFontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute];

    NSLog(@"Chapter listing font size: %f", bodyFontSize.floatValue);
    
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute : @"Interstate"}];
    return [UIFont fontWithDescriptor: fontDescriptor size: bodyFontSize.floatValue];
}

+ (CGFloat)aig_preferredSizeForDesignSize:(CGFloat)designSize
{
    UIFontDescriptor *normalFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    CGFloat mediumFontSize = 17;
    NSNumber *bodyFontSize = normalFontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute];
    CGFloat scaleFactor = bodyFontSize.floatValue/mediumFontSize;
    
    return designSize * scaleFactor;
}

+ (UIFont *)aig_RegularFontOfSize:(NSUInteger)size
{
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute : @"Interstate"}];
    UIFont *font = [UIFont fontWithDescriptor: fontDescriptor size: [self aig_preferredSizeForDesignSize:size]];
    return font;
}

+ (UIFont *)aig_BoldFontOfSize:(NSUInteger)size
{
    UIFont *font = [UIFont fontWithName:@"Interstate-Bold" size: [self aig_preferredSizeForDesignSize:size]];
    return font;
}

@end
