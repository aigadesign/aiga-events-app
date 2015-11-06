//
//  AIGAppDelegate.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)reloadEventDataWithRefreshCompletionHandler:(void (^)(UIBackgroundFetchResult))refreshCompletionHandler;
- (void)refreshChapterListWithCompletionHandler:(void (^)(NSArray *allChapters, NSError *error))completionHandler;

+ (AIGAppDelegate *)sharedAppDelegate;

@end
