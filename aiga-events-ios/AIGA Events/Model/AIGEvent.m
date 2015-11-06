//
//  AIGEvent.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/18/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGEvent+Extensions.h"
#import "AIGChapter.h"
#import "AIGEventTicket.h"
#import "NSDate+Extensions.h"
#import "AIGEventLocation.h"
#import "AIGEventTicket.h"
#import "AIGCoreDataManager.h"
#import "AIGEventDataDownloadManager.h"
#import "NSDate+Extensions.h"
#import "NSString+AIGAExtensions.h"
#import "NSString+HTML.h"

@implementation AIGEvent

@dynamic address;
@dynamic endTime;
@dynamic eventDescription;
@dynamic abbrevDescription;
@dynamic eventBriteID;
@dynamic eTouchesID;
@dynamic eventTitle;
@dynamic mainImageData;
@dynamic thumbnailData;
@dynamic startTime;
@dynamic timestamp;
@dynamic venueName;
@dynamic chapter;
@dynamic latitude;
@dynamic longitude;
@dynamic tickets;
@dynamic registerURL;

@dynamic thumbnailImage;

@end
