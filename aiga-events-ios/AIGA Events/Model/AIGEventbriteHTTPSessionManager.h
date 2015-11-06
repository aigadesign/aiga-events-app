//
//  AIGEventbriteHTTPSessionManager.h
//  AIGA Events
//
//  Created by Dennis Birch on 12/10/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AIGEventbriteHTTPSessionManager : AFHTTPSessionManager

+ (AIGEventbriteHTTPSessionManager *)sharedEventbriteHTTPSessionManager;

@end
