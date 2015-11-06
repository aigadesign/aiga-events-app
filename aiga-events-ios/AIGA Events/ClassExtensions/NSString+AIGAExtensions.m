//
//  NSString+AIGAExtensions.m
//  AIGA Events
//
//  Created by Tony Bentley on 11/27/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "NSString+AIGAExtensions.h"

@implementation NSString (AIGAExtensions)


- (NSString *) aig_ScrubHTML
{
    
    NSString *tagPattern = @"<[^>]+>";
    NSString *periodPattern = @" *";
    NSString *newLinePattern = @"\r?\n";
    
    NSRegularExpression *regexHMTL = [NSRegularExpression regularExpressionWithPattern:tagPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *regexNewLine = [NSRegularExpression regularExpressionWithPattern:newLinePattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *regexPeriods = [NSRegularExpression regularExpressionWithPattern:periodPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSRange range = NSMakeRange(0, [self length]);
    NSString *noHTML = [regexHMTL stringByReplacingMatchesInString:self options:0 range:range withTemplate:@""];
    
    NSRange rangeHTML = NSMakeRange(0, [noHTML length]);
    NSString *noNewLines = [regexNewLine stringByReplacingMatchesInString:noHTML options:0 range:rangeHTML withTemplate:@" "];
    
    NSRange rangePeriods = NSMakeRange(0, [noNewLines length]);
    NSString *noExtraPeriods = [regexPeriods stringByReplacingMatchesInString:noNewLines options:0 range:rangePeriods withTemplate:@""];
    
    return noExtraPeriods;
}



@end
