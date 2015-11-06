//
//  AIGEventDetailLocationTimeView.h
//  AIGA Events
//
//  Created by Dennis Birch on 11/14/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AIGEvent;
@protocol DetailLocationTimeViewDelegate;

@interface AIGEventDetailLocationTimeView : UIView

@property (nonatomic, strong) AIGEvent *currentEvent;
@property (nonatomic, weak) id <DetailLocationTimeViewDelegate> delegate;

@end


@protocol DetailLocationTimeViewDelegate <NSObject>

- (void)mapButtonTouched;
- (void)calendarButtonTapped;
- (void)registerButtonTapped;

@end