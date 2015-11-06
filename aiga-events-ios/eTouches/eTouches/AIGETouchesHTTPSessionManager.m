//
//  AIGETouchesHTTPSessionManager.m
//  eTouches
//
//  Created by Dennis Birch on 12/9/13.
//  Copyright (c) 2013 DeloitteDigital. All rights reserved.
//

#import "AIGETouchesHTTPSessionManager.h"

@implementation AIGETouchesHTTPSessionManager

static NSString *ETOUCHES_BASE_URL = @"https://www.eiseverywhere.com/";

+ (AIGETouchesHTTPSessionManager *)sharedETouchesHTTPSessionManager
{
    static AIGETouchesHTTPSessionManager *sessionManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:ETOUCHES_BASE_URL];
        sessionManager = [[AIGETouchesHTTPSessionManager alloc] initWithBaseURL:url];
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return sessionManager;
}

@end
