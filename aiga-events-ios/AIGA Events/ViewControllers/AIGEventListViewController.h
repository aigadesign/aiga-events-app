//
//  AIGEventListViewController.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIGChapterViewController.h"
#import "AIGNoChaptersBlockingViewController.h"

@interface AIGEventListViewController : AIGNoChaptersBlockingViewController

- (void)reloadEventDataWithRefreshCompletionHandler:(void (^)(UIBackgroundFetchResult))refreshCompletionHandler;

@end
