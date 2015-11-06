//
//  AIGCalendarViewController.h
//  AIGA Events
//
//  Created by Dennis Birch on 11/6/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIGNoChaptersBlockingViewController.h"

@interface AIGCalendarViewController : AIGNoChaptersBlockingViewController

- (void)reloadEventDataWithRefreshCompletionHandler:(void (^)(UIBackgroundFetchResult))refreshCompletionHandler;

@end
