//
//  AIGEventCell.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventCell.h"
#import "AIGEvent+Extensions.h"
#import "AIGChapter.h"
#import "UIFont+AIGAExtensions.h"
#import "AIGEventCell+Geometry.h"
#import "UIColor+Extensions.h"
#import "NSString+HTML.h"

@interface AIGEventCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *detailsArrowImageView;
@property (weak, nonatomic) IBOutlet UIView *dummyView;
@property (nonatomic, strong) UIImage *thumbImage;

@end


@implementation AIGEventCell


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor aig_TableViewBackgroundColor];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (UIImage *)placeholderThumbnail
{
    return [UIImage imageNamed:@"aiga-logo"];
}

-(UIImage *)thumbnailImageForEvent:(AIGEvent *)event;
{
    BOOL saveThumbnailData = NO;
    
    if (event.thumbnailImage != nil) {
        return event.thumbnailImage;
    }
    
    if (_thumbImage == nil) {
        NSData *data = event.thumbnailData;
        
        if (data == nil) {
            data = event.mainImageData;
            saveThumbnailData = YES;
        }
        
        if (data == nil) {
            return [AIGEventCell placeholderThumbnail];
        }
        
        UIImage *image = [UIImage imageWithData:data];
        if (image.size.width <= 38.0f) {
            _thumbImage = image;
            event.thumbnailImage = image;
            return _thumbImage;
        }
        
        // in case thumbnail data wasn't saved when downloaded, we need to scale image here
        float scalingFactor = 38.0/image.size.width;
        CGSize newSize = CGSizeMake(image.size.width * scalingFactor, image.size.width * scalingFactor);
        
        UIGraphicsBeginImageContext( newSize );
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (saveThumbnailData) {
            event.thumbnailData = UIImagePNGRepresentation(newImage);
            event.thumbnailImage = newImage;
         }
        
        _thumbImage = newImage;
    }
    
    return _thumbImage;
}

- (CGFloat)cellHeightForEvent:(AIGEvent *)event
{
    [self populateFromEvent:event];
    [self layoutIfNeeded];
    
    // a fix for a weird bug in iOS 7, which is the only place where this code is called
    CGFloat titleHeight = self.titleLabel.bounds.size.height;
    CGFloat descHeight = self.descriptionLabel.bounds.size.height;
    CGFloat locHeight = MAX(self.locationLabel.bounds.size.height, self.dateLabel.bounds.size.height);
    CGFloat detailsHeight = 21.0f; // from the XIB
    CGFloat padding = 74;
    return titleHeight + descHeight + locHeight + detailsHeight + padding;
}

-(void)populateFromEvent:(AIGEvent *)event
{
    _event = event;
    
    self.dateLabel.textColor = [UIColor aig_EventDateAndLocationTextColor];
    self.locationLabel.textColor = [UIColor aig_EventDateAndLocationTextColor];
    self.detailsLabel.textColor = [UIColor aig_LightBlueColor];
    self.descriptionLabel.textColor = [UIColor aig_EventDescriptionTextColor];
    self.thumbnailImageView.image = [self thumbnailImageForEvent:event];
    
    if (event == nil)
    {
        if (self.isInCalendarList)
        {
            self.titleLabel.attributedText = [AIGEventCell aig_AttributedStringForTitle:@"THERE ARE NO EVENTS FOR THIS DATE"];
        }
        else
        {
            self.titleLabel.attributedText = [AIGEventCell aig_AttributedStringForTitle:@"THERE ARE NO EVENTS FOR THIS CHAPTER"];
        }
        
        self.dateLabel.text = @"";
        self.locationLabel.text = @"";
        self.descriptionLabel.text = @"";
        self.detailsLabel.hidden = YES;
        self.detailsArrowImageView.hidden = YES;
        self.userInteractionEnabled = NO;
        
    }
    else
    {
        self.descriptionLabel.hidden = self.isInCalendarList;
        self.titleLabel.attributedText = [AIGEventCell aig_AttributedStringForTitle:[event.eventTitle uppercaseString]];
        NSString *labelText = [[event eventDateRange] stringByAppendingString:@" "];
        self.dateLabel.attributedText = [AIGEventCell aig_AttributedStringForDate:labelText];
        self.locationLabel.attributedText = [AIGEventCell aig_AttributedStringForDate:[self locationForEvent:event]];
        
        if (!self.isInCalendarList)
        {
            self.descriptionLabel.attributedText = [AIGEventCell aig_AttributedStringForDescription:event.abbrevDescription];
        }
        else
        {
            self.descriptionLabel.attributedText = nil;
            self.descriptionLabel.text = nil;
        }
        
        self.detailsLabel.attributedText = [AIGEventCell aig_AttributedStringForDetailsLabel:NSLocalizedString(@"Details", nil)];
     }
}

- (NSString *)locationForEvent:(AIGEvent *)event
{
    NSString *location;
    if (self.isInCalendarList) {
        location = [event.chapter.city uppercaseString];
    } else {
        if (event.venueName == nil) {
            location = @" ";
        } else {
            location = [[event.venueName kv_decodeHTMLCharacterEntities] uppercaseString];
        }
    }
    
    location = [location kv_decodeHTMLCharacterEntities];
    return [location stringByAppendingString:@" "];
}

- (void)prepareForReuse
{
    self.titleLabel.attributedText = nil;
    self.dateLabel.attributedText = nil;
    self.descriptionLabel.attributedText = nil;
    self.locationLabel.attributedText = nil;
    self.userInteractionEnabled = YES;
    self.detailsArrowImageView.hidden = NO;
    self.detailsLabel.hidden = NO;
    self.thumbImage = nil;
}

@end
