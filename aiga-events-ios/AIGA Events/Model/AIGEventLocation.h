//
//  AIGEventLocation.h
//  AIGA Events
//
//  Created by Dennis Birch on 11/1/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface AIGEventLocation : NSObject <MKAnnotation>

- (instancetype)initWithLatitude:(float)latitude
                       longitude:(float)longitude
                 annotationTitle:(NSString *)annotationTitle
                        subTitle:(NSString *)subTitle;

@end
