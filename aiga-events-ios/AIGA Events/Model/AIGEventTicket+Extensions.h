//
//  AIGEventTicket+Extensions.h
//  AIGA Events
//
//  Created by George McCarroll on 1/7/14.
//  Copyright (c) 2014 Deloitte Digital. All rights reserved.
//

#import "AIGEventTicket.h"

#define kEventTicketEntity  @"AIGEventTicket"

@interface AIGEventTicket (Extensions)

+ (NSSet *)ticketsFromImportedData:(NSArray *)ticketsArray;

@end
