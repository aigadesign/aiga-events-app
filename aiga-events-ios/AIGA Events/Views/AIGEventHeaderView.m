//
//  AIGEventHeaderView.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/25/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventHeaderView.h"
#import "AIGChapter.h"
#import "UIFont+AIGAExtensions.h"
#import "UIColor+Extensions.h"

@interface AIGEventHeaderView ()

@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UILabel *cityLabel;

@end


@implementation AIGEventHeaderView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setup];
     }
    
    return self;
}


- (void)setChapter:(AIGChapter *)chapter previousChapter:(AIGChapter *)previousChapter nextChapter:(AIGChapter *)nextChapter
{
    _chapter = chapter;
    [self displayCityForChapter:chapter previousChapter:previousChapter nextChapter:nextChapter];
}

- (void)displayCityForChapter:(AIGChapter *)chapter previousChapter:(AIGChapter *)previousChapter nextChapter:(AIGChapter *)nextChapter
{
    NSString *city = (chapter == nil) ? @"" : chapter.city;
    
    self.cityLabel.text = city;
    self.previousButton.hidden = (previousChapter == nil);
    self.nextButton.hidden = (nextChapter == nil);
}

- (void)setChapterName:(NSString *)chapterName
{
    self.cityLabel.text = chapterName;
}

- (void)setup
{
    self.backgroundColor = [UIColor aig_TableViewBackgroundColor];
    
    _cityLabel = [[UILabel alloc] init];
    _cityLabel.font = [UIFont fontWithName:@"Interstate-Regular" size:18];
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.textColor = [UIColor aig_LightBlueColor];
//    [self displayCityForChapter:_chapter previousChapter:nil nextChapter:nil];
    [self addSubview:_cityLabel];
    
    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextButton setImage:[UIImage imageNamed:@"location_forward"]
                forState:UIControlStateNormal];
    [_nextButton addTarget:self
                   action:@selector(nextButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    _nextButton.backgroundColor = [UIColor clearColor];
    [self addSubview:_nextButton];

    _previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previousButton setImage:[UIImage imageNamed:@"location_back"]
                forState:UIControlStateNormal];
    [_previousButton addTarget:self
                   action:@selector(previousButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    _previousButton.backgroundColor = [UIColor clearColor];
    [self addSubview:_previousButton];

    _cityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _previousButton.translatesAutoresizingMaskIntoConstraints = NO;
    _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *metrics = @{@"buttonWidth" : @(44.)};
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_cityLabel, _nextButton, _previousButton);

    // horizontal constraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_cityLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(4)-[_previousButton(==buttonWidth)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewsDict]];


    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_nextButton(==buttonWidth)]-(4)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewsDict]];

    // vertical constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nextButton]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_previousButton]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewsDict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_cityLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
}

- (IBAction)nextButtonTapped:(id)sender
{
    [self.delegate nextChapterButtonTapped];
}

- (IBAction)previousButtonTapped:(id)sender
{
    [self.delegate previousChapterButtonTapped];
}

- (NSString *)description
{
    return self.chapter.city;
}

@end
