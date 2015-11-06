//
//  AIGEventTicket+Extensions.m
//  AIGA Events
//
//  Created by George McCarroll on 1/7/14.
//  Copyright (c) 2014 Deloitte Digital. All rights reserved.
//

#import "AIGEventTicket+Extensions.h"

@implementation AIGEventTicket (Extensions)

+ (NSSet *)ticketsFromImportedData:(NSArray *)ticketsArray
{
    // turn imported ticket info into data objects
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *wrapper in ticketsArray) {
        AIGEventTicket *ticket = [AIGEventTicket createEntity];
        NSDictionary *dict = wrapper[@"ticket"];
        ticket.title = dict[@"name"];
        if ([dict objectForKey:@"display_price"] != nil) {
            ticket.cost = [NSDecimalNumber decimalNumberWithString:dict[@"display_price"]];
        }
        [array addObject:ticket];
    }
    
    return [NSSet setWithArray:array];
}

@end
