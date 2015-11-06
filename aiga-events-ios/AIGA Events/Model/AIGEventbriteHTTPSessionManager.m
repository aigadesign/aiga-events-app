//
//  AIGEventbriteHTTPSessionManager.m
//  AIGA Events
//
//  Created by Dennis Birch on 12/10/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventbriteHTTPSessionManager.h"

@implementation AIGEventbriteHTTPSessionManager

static NSString *EVENTBRITE_EVENT_URL = @"https://www.eventbrite.com";

+ (AIGEventbriteHTTPSessionManager *)sharedEventbriteHTTPSessionManager
{
    static AIGEventbriteHTTPSessionManager *sessionManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:EVENTBRITE_EVENT_URL];
        sessionManager = [[AIGEventbriteHTTPSessionManager alloc] initWithBaseURL:url];
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return sessionManager;
}

@end
