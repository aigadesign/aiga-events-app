//
//  AIGEventHeaderView.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/25/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AIGChapter;

@protocol AIGEventHeaderDelegate;

@interface AIGEventHeaderView : UIView

@property (nonatomic, strong) AIGChapter *chapter;
@property (nonatomic, weak) id <AIGEventHeaderDelegate> delegate;
@property (nonatomic, assign) BOOL navArrowsVisible;

- (void)setChapter:(AIGChapter *)chapter previousChapter:(AIGChapter *)previousChapter nextChapter:(AIGChapter *)nextChapter;
- (void)setChapterName:(NSString *)chapterName;

@end

@protocol AIGEventHeaderDelegate <NSObject>

- (void)nextChapterButtonTapped;
- (void)previousChapterButtonTapped;

@end