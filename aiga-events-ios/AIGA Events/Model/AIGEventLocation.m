//
//  AIGEventLocation.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/1/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEventLocation.h"
#import "NSString+HTML.h"

@interface AIGEventLocation ()

@property (nonatomic, assign) float latValue;
@property (nonatomic, assign) float longValue;
@property (nonatomic, copy) NSString *annotationTitle;
@property (nonatomic, copy) NSString *subTitle;

@end

@implementation AIGEventLocation

- (instancetype)initWithLatitude:(float)latitude longitude:(float)longitude annotationTitle:(NSString *)annotationTitle subTitle:(NSString *)subTitle
{
    self = [super init];
    if (self) {
        _latValue = latitude;
        _longValue = longitude;
        _annotationTitle = annotationTitle;
        _subTitle = subTitle;
    }
    
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.latValue, self.longValue);
    return location;
}

- (NSString *)title
{
    if (self.annotationTitle == nil) {
        return @"";
    }
    return [self.annotationTitle kv_decodeHTMLCharacterEntities];
}

- (NSString *)subtitle
{
    if (self.subTitle == nil) {
        return @"";
    }
    return self.subTitle;
}

@end
