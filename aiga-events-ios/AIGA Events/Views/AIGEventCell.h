//
//  AIGEventCell.h
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIGEvent+Extensions.h"

#define kLabelCellMargin        48.0
#define kCellLabelWidth         246.0

#define kLabelLeft              54.0
#define kLabelTop               25.0
#define kIconHeight             15.0
#define kVerticalLabelSpacing   3.0
#define kHorizontalLabelSpacing 4.0
#define kEventCellLeftMargin     8.0


@interface AIGEventCell : UITableViewCell

@property (nonatomic, strong) AIGEvent *event;

@property (nonatomic, assign) BOOL isInCalendarList;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

+ (UIImage *)placeholderThumbnail;

-(void)populateFromEvent:(AIGEvent *)event;
- (CGFloat)cellHeightForEvent:(AIGEvent *)event;
@end
