//
//  AIGETouchesHTTPSessionManager.h
//  eTouches
//
//  Created by Dennis Birch on 12/9/13.
//  Copyright (c) 2013 DeloitteDigital. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AIGETouchesHTTPSessionManager : AFHTTPSessionManager

+ (AIGETouchesHTTPSessionManager *)sharedETouchesHTTPSessionManager;

@end
