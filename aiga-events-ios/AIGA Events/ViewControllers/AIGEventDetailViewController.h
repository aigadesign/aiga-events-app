//
//  AIGEventDetailViewController.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/29/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AIGEvent;
@protocol EventDetailViewDelegate;

@interface AIGEventDetailViewController : UIViewController

@property (nonatomic, strong) AIGEvent *currentEvent;

@end
