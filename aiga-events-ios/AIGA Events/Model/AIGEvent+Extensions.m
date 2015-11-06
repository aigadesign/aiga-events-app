//
//  AIGEvent+Extensions.m
//  AIGA Events
//
//  Created by George McCarroll on 1/7/14.
//  Copyright (c) 2014 Deloitte Digital. All rights reserved.
//

#import "AIGEvent+Extensions.h"
#import "AIGChapter+Extensions.h"
#import "AIGChapter.h"
#import "AIGEventTicket+Extensions.h"
#import "NSDate+Extensions.h"
#import "AIGEventLocation.h"
#import "AIGEventTicket.h"
#import "AIGCoreDataManager.h"
#import "AIGEventDataDownloadManager.h"
#import "NSDate+Extensions.h"
#import "NSString+AIGAExtensions.h"
#import "NSString+HTML.h"

@implementation AIGEvent (Extensions)

static NSString *EtouchesServiceIdentifier = @"eTouches";
static NSString *EventBriteServiceIdentifier = @"eventBritesID";

- (NSString *)eventDateRange
{
    NSString *result;
    
    if (self.endTime == nil) {
        result = [[self.startTime aig_ShortFormattedDate]uppercaseString];
    } else {
        if ([self.startTime aig_IsSameDay:self.endTime]) {
            result = [NSString stringWithFormat:@"%@, %@ - %@", [[self.startTime aig_ShortFormattedDate] uppercaseString],
                      [[self.startTime aig_FormattedTime]uppercaseString],
                      [[self.endTime aig_FormattedTime] uppercaseString]];
        } else {
            result = [NSString stringWithFormat:@"%@ - %@", [[self.startTime aig_ShortFormattedDate] uppercaseString],
                      [[self.endTime aig_ShortFormattedDate]uppercaseString]];
        }
    }
    
    return result;
}


- (AIGEventLocation *)eventLocation
{
    NSString *title = self.venueName.length == 0 ? self.eventTitle : self.venueName;
    
    AIGEventLocation *location = [[AIGEventLocation alloc] initWithLatitude:self.latitude.floatValue
                                                                  longitude:self.longitude.floatValue
                                                            annotationTitle:title
                                                                   subTitle:self.address];
    
    return location;
}

-(NSString *)trimmedAddress
{
    return [self.address stringByReplacingOccurrencesOfString:@"(null), " withString:@""];
}

- (UIImage *)mainImage
{
    UIImage *image;
    NSData *data = self.mainImageData;
    if (data == nil) {
        return [UIImage imageNamed:@"placeholder"];
    }
    
    image = [UIImage imageWithData:data];
    
    return image;
}

- (NSString *)eventPriceRange
{
    NSString *priceRange = @"PRICING NOT AVAILABLE";
    if (self.tickets.count == 0) {
        return priceRange;
    }
    
    float minPrice = NAN;
    float maxPrice = NAN;
    BOOL firstTime = YES;
    
    for(AIGEventTicket *ticket in self.tickets) {
        if(firstTime) {
            minPrice = maxPrice = [ticket.cost floatValue];
            firstTime = NO;
            continue;
        }
        minPrice = fmin(minPrice, [ticket.cost floatValue]);
        maxPrice = fmax(maxPrice, [ticket.cost floatValue]);
    }
    
    NSString *minPriceString = @"";
    if (minPrice == 0) {
        minPriceString = @"FREE";
    } else {
        minPriceString = [NSString stringWithFormat:@"$%.02f", minPrice];;
    }
    
    priceRange = minPriceString;
    if (maxPrice > 0) {
        priceRange = [NSString stringWithFormat:@"%@ - %@", priceRange, [NSString stringWithFormat:@"$%.02f", maxPrice]];
    }
    
    return priceRange;
}

+ (NSArray *)eventsForChapter:(AIGChapter *)chapter
{
    NSDate *today = [[NSDate date] aig_TruncatedDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chapter.city = %@ AND endTime >= %@", chapter.city, today];
    
    NSError *error = nil;
    NSArray *result = [AIGEvent findAllSortedBy:@"startTime" ascending:YES withPredicate:predicate];
    if (result == nil) {
        NSLog(@"Error fetching events for chapter %@: %@", chapter.city, [error localizedDescription]);
        return nil;
    }
    
    return result;
}

+(NSUInteger)countOfEventsForChapter:(AIGChapter *)chapter
{
    NSDate *today = [[NSDate date] aig_TruncatedDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chapter.city = %@ AND endTime >= %@", chapter.city, today];
    
    return [AIGEvent countOfEntitiesWithPredicate:predicate];
}

+ (void)importETouchesEvents:(NSArray *)eventsArray
                  forChapter:(AIGChapter *)chapter
           completionHandler:(void (^)(BOOL hasChanges))completionHandler
{
    // handle an array of ETouches Events data for one chapter
    
    // get a reference for all IDs we have already
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chapter.city = %@", chapter.city];
    NSError *error = nil;
    NSArray *allEvents = [AIGEvent findAllWithPredicate:predicate];
    if (allEvents == nil) {
        ALog(@"Error fetching events for %@: %@", chapter.city, [error localizedDescription]);
        return;
    }
    
    NSMutableArray *eventIDs = [NSMutableArray arrayWithCapacity:allEvents.count];
    NSMutableArray *timestamps = [NSMutableArray arrayWithCapacity:allEvents.count];
    NSMutableArray *foundEvents = [NSMutableArray arrayWithCapacity:allEvents.count];
    [allEvents enumerateObjectsUsingBlock:^(AIGEvent *event, NSUInteger idx, BOOL *stop) {
        [eventIDs addObject:event.eTouchesID];
        [timestamps addObject:event.timestamp];
        [foundEvents addObject:@(NO)];
    }];
    
    BOOL newData = NO;

    for (NSDictionary *oneEventDict in eventsArray) {
        
        //only import live events
        if (![[oneEventDict[@"status"] lowercaseString] isEqualToString:@"live"]) {
            continue;
        }
        
        NSString *idStr = oneEventDict[@"eventid"];
        NSNumber *eTouchesID = @(idStr.integerValue);
        NSUInteger found = [eventIDs indexOfObject:eTouchesID];
        NSDate *incomingTimestamp = nil;
        
        // get a timestamp for the event from the incoming data
        NSDate *created = [NSDate aig_EventBriteDateWithString:oneEventDict[@"createddatetime"]];
        NSDate *modified = [NSDate aig_EventBriteDateWithString:oneEventDict[@"modifieddatetime"]];
        incomingTimestamp = (modified == nil) ? created : modified;
        
        AIGEvent *newEvent;
        
        if (found == NSNotFound) {
            newEvent = [AIGEvent createEntity];
            
        } else {
            
            // compare incoming timestamp to the timestamp we have for the event to see if it's been modified
            NSDate *lastTime = timestamps[found];
            foundEvents[found] = @(YES);
            
            if ([incomingTimestamp earlierDate:lastTime] == incomingTimestamp) {
                
                // see if we need to try downloading images
                NSNumber *eventID = @(idStr.integerValue);
                AIGEvent *event = [chapter eventWithID:eventID];
                NSString *imageURL = oneEventDict[@"clientcontact"];
                if (event.mainImageData == nil) {
                    [self downloadImageWithURL:imageURL event:event eventID:eventID isThumbnail:NO serviceIdentifier:EtouchesServiceIdentifier];
                }
                if (event.thumbnailData == nil) {
                    imageURL = oneEventDict[@"programmanager"];
                    [self downloadImageWithURL:imageURL event:event eventID:eventID isThumbnail:YES serviceIdentifier:EtouchesServiceIdentifier];
                }
                
                // we have the freshest version, so go to the next
                continue;
            }
        }
        
        if (newEvent == nil) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eTouchesID = %@", eTouchesID];
            
            newEvent = [AIGEvent findFirstWithPredicate:predicate];
            
            if (newEvent == nil) {
                // something went wrong
                NSLog(@"Error: Couldn't update Etouches event with id: %@", eTouchesID);
                continue;
            }
        }
        
        newData = YES;
        
        NSString *eventTitle = [oneEventDict[@"name"] kv_decodeHTMLCharacterEntities];
        newEvent.eventTitle = eventTitle;
        
        // get images
        NSString *imageURL = oneEventDict[@"clientcontact"];
        // download main image
        [self downloadImageWithURL:imageURL event:newEvent eventID:eTouchesID isThumbnail:NO serviceIdentifier:EtouchesServiceIdentifier];
        // download thumbnail
        imageURL = oneEventDict[@"programmanager"];
        [self downloadImageWithURL:imageURL event:newEvent eventID:eTouchesID isThumbnail:YES serviceIdentifier:EtouchesServiceIdentifier];
        
        if (![oneEventDict[@"url"] isEqualToString:@"(null)"]) {
            newEvent.registerURL = oneEventDict[@"url"];
        }
        else
        {
            newEvent.registerURL = nil;
        }
        
        NSString *description = oneEventDict[@"description"];
        
        newEvent.eventDescription = description;
        
        if ([description length] > 0) {
            
            NSString *blurb = [oneEventDict[@"description"] aig_ScrubHTML];
            
            if ([blurb length] > 200) {
                newEvent.abbrevDescription = [blurb substringToIndex:200];
            } else {
                newEvent.abbrevDescription = blurb;
            }
            
        } else {
            newEvent.abbrevDescription = @"Description not available.";
        }
        
        NSDictionary *location = oneEventDict[@"location"];
        newEvent.venueName = location[@"name"];
        NSString *address1 = [location[@"address1"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *address2 = [location[@"address2"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *address;
        
        if (address1.length > 0 && address2.length > 0) {
            address = [NSString stringWithFormat:@"%@, %@", address1, address2];
        } else if (address2.length == 0) {
            address = address1;
        } else {
            address = address2;
        }
        
        NSString *city = location[@"city"];
        if (city.length > 0) {
            address = [NSString stringWithFormat:@"%@, %@", address, city];
        }
        newEvent.address = address;
        
        NSString *startTime = oneEventDict[@"starttime"];
        NSString *endTime = oneEventDict[@"endtime"];
        NSString *startDate = oneEventDict[@"startdate"];
        NSString *endDate = oneEventDict[@"enddate"];
        
        startTime = [startDate stringByAppendingFormat:@" %@", startTime];
        endTime = [endDate stringByAppendingFormat:@" %@", endTime];
        
        newEvent.startTime = [NSDate aig_EventBriteDateWithString:startTime];
        newEvent.endTime = [NSDate aig_EventBriteDateWithString:endTime];
        
        newEvent.eTouchesID = eTouchesID;
        
        newEvent.timestamp = incomingTimestamp;
        
        newEvent.chapter = chapter;
    }

    //Delete old events that were not updated
    for (NSUInteger ii=0; ii<eventIDs.count; ii++) {
        if (![foundEvents[ii]boolValue]) {
            //remove only events we did not find in the update
            NSNumber *eTouchesID = eventIDs[ii];
            if ([eTouchesID intValue]!=0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eTouchesID = %@", eTouchesID];
                NSUInteger deleteCount = [AIGEvent countOfEntitiesWithPredicate:predicate];
                if (deleteCount>0) {
                    NSLog(@"Deleting Etouches events matching ID=%@, count=%ld", eTouchesID, (unsigned long)deleteCount);
                    [AIGEvent deleteAllMatchingPredicate:predicate];
                }
            }
        }
    }
    
    if (completionHandler != nil) {
        completionHandler(newData);
    }
}

+ (void)importEventbriteEvents:(NSDictionary *)eventsDict
                    forChapter:(AIGChapter *)chapter
                   dataManager:(AIGCoreDataManager *)coreDataManager
             completionHandler:(void (^)(BOOL hasChanges))completionHandler
{
    // handle a dictionary of incoming events data for one chapter
    
    // get a reference for all IDs we have already
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chapter.city = %@", chapter.city];
    NSError *error = nil;
    NSArray *allEvents = [AIGEvent findAllWithPredicate:predicate];
    if (allEvents == nil) {
        ALog(@"Error fetching events for %@: %@", chapter.city, [error localizedDescription]);
        return;
    }
    
    NSMutableArray *eventIDs = [NSMutableArray arrayWithCapacity:allEvents.count];
    NSMutableArray *timestamps = [NSMutableArray arrayWithCapacity:allEvents.count];
    NSMutableArray *foundEvents = [NSMutableArray arrayWithCapacity:allEvents.count];
    [allEvents enumerateObjectsUsingBlock:^(AIGEvent *event, NSUInteger idx, BOOL *stop) {
        [eventIDs addObject:event.eventBriteID];
        [timestamps addObject:event.timestamp];
        [foundEvents addObject:@(NO)];
    }];
    
    // now we have an array of all IDs in data store
    NSArray *incomingEvents = eventsDict[@"events"];
    
    BOOL newData = NO;
    
    for (NSDictionary *eventWrapper in incomingEvents) {
        if (eventWrapper[@"summary"] != nil) {
            // check to see if image needs to be updated
            continue;
        }
        
        NSDictionary *oneEventDict = eventWrapper[@"event"];
        
        //only import live events
        if (![[oneEventDict[@"status"] lowercaseString] isEqualToString:@"live"]) {
            continue;
        }
        
        NSNumber *incomingID = oneEventDict[@"id"];
        NSUInteger found = [eventIDs indexOfObject:incomingID];
        NSDate *incomingTimestamp = nil;
        
        // get a timestamp for the event from the incoming data
        NSDate *created = [NSDate aig_EventBriteDateWithString:oneEventDict[@"created"]];
        NSDate *modified = [NSDate aig_EventBriteDateWithString:oneEventDict[@"modified"]];
        incomingTimestamp = (modified == nil) ? created : modified;
        
        AIGEvent *newEvent;
        
        if (found == NSNotFound) {
            newEvent = [AIGEvent createEntity];
            
        } else {
            // compare incoming timestamp to the timestamp we have for the event to see if it's been modified
            NSDate *lastTime = timestamps[found];
            foundEvents[found] = @(YES);

            if ([incomingTimestamp earlierDate:lastTime] == incomingTimestamp) {
                AIGEvent *event = [chapter eventWithID:incomingID];
                if (event.mainImageData == nil) {
                    // try to redownload
                    NSString *imageDownload = oneEventDict[@"logo"];
                    [self downloadImageWithURL:imageDownload event:event eventID:event.eventBriteID isThumbnail:NO serviceIdentifier:EventBriteServiceIdentifier];
                }
                // try to redownload
                continue;
            }
        }
        
        if (newEvent == nil) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventBriteID = %@", incomingID];
            
            newEvent = [AIGEvent findFirstWithPredicate:predicate];
            
            if (newEvent == nil) {
                // something went wrong
                NSLog(@"Error: Couldn't update EventBrite event with id: %@", incomingID);
                continue;
            }
        }
        
        newData = YES;
        
        NSString *eventTitle = [oneEventDict[@"title"] kv_decodeHTMLCharacterEntities];
        newEvent.eventTitle = eventTitle;
        
        NSNumber *eventBriteID = oneEventDict[@"id"];
        
        // get the image
        NSString *imageURL = oneEventDict[@"logo"];
        [self downloadImageWithURL:imageURL event:newEvent eventID:eventBriteID isThumbnail:NO serviceIdentifier:EventBriteServiceIdentifier];
        
        if (![oneEventDict[@"url"] isEqualToString:@"(null)"]) {
            newEvent.registerURL = oneEventDict[@"url"];
        }
        else
        {
            newEvent.registerURL = nil;
        }
        
        NSString *description = oneEventDict[@"description"];
        
        newEvent.eventDescription = description;
        
        if ([description length] > 0) {
            
            NSString *blurb = [oneEventDict[@"description"] aig_ScrubHTML];
            
            if ([blurb length] > 200) {
                newEvent.abbrevDescription = [blurb substringToIndex:200];
                
            } else {
                newEvent.abbrevDescription = blurb;
            }
            
        } else {
            newEvent.abbrevDescription = @"Description not available.";
        }
        
        NSDictionary *venue = oneEventDict[@"venue"];
        newEvent.venueName = venue[@"name"];
        newEvent.latitude = venue[@"latitude"];
        newEvent.longitude = venue[@"longitude"];
        
        NSString *address1 = [venue[@"address"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *address2 = [venue[@"address_2"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *address;
        
        if (address1.length > 0 && address2.length > 0) {
            address = [NSString stringWithFormat:@"%@, %@", address1, address2];
        } else if (address2.length == 0) {
            address = address1;
        } else {
            address = address2;
        }
        
        NSString *city = venue[@"city"];
        if (city.length > 0) {
            address = [NSString stringWithFormat:@"%@, %@", address, city];
        }
        newEvent.address = address;
        newEvent.startTime = [NSDate aig_EventBriteDateWithString:oneEventDict[@"start_date"]];
        newEvent.endTime = [NSDate aig_EventBriteDateWithString:oneEventDict[@"end_date"]];
        
        NSArray *tickets = oneEventDict[@"tickets"];
        newEvent.tickets = [AIGEventTicket ticketsFromImportedData:tickets];
        
        newEvent.eventBriteID = eventBriteID;
        
        newEvent.timestamp = incomingTimestamp;
        
        newEvent.chapter = chapter;
    }
    
    //Delete old events that were not updated
    for (NSUInteger ii=0; ii<eventIDs.count; ii++) {
        if (![foundEvents[ii] boolValue]) {
            //remove only events we did not find in the update
            NSNumber *eventBriteID = eventIDs[ii];
            if ([eventBriteID intValue]!=0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventBriteID = %@", eventBriteID];
                NSUInteger deleteCount = [AIGEvent countOfEntitiesWithPredicate:predicate];
                if (deleteCount>0) {
                    NSLog(@"Deleting Eventbrite events matching ID=%@, count=%ld", eventBriteID, (unsigned long)deleteCount);
                    [AIGEvent deleteAllMatchingPredicate:predicate];
                }
            }
        }
    }
    
    if (completionHandler != nil) {
        completionHandler(newData);
    }
}

+ (void)downloadImageWithURL:(NSString *)imageURL event:(AIGEvent *)newEvent eventID:(NSNumber *)eventID isThumbnail:(BOOL)isThumbnail serviceIdentifier:(NSString *)serviceIdentifier
{
    [[AIGEventDataDownloadManager
      sharedEventDataDownloadManager] downloadImageForEventWithPath:imageURL
     completionHandler:^(UIImage *image, NSError *error) {
        if (image == nil) {
             NSLog(@"Error downloading image for %@: %@", newEvent.eventTitle, [error localizedDescription]);
         } else {
             NSData *imageData = UIImagePNGRepresentation(image);
             if (isThumbnail) {
                 newEvent.thumbnailData = imageData;
             } else {
                 newEvent.mainImageData = imageData;
             }
             
             [[AIGCoreDataManager sharedCoreDataManager] saveContextAndWait:NO];
             
             [self checkThumbnailImageForEvent:newEvent];
             
             NSDictionary *userInfo = @{serviceIdentifier : eventID};
             [[NSNotificationCenter defaultCenter] postNotificationName:ImageDownloadCompletionNotification
                                                                 object:nil
                                                               userInfo:userInfo];
         }
     }];
}

+ (void)checkThumbnailImageForEvent:(AIGEvent *)event
{
    // check thumbnail image for proper size and create a small size if not available
    // if there is thumbnail data, work with that
    NSData *thumbnailData = event.thumbnailData;
    if (thumbnailData == nil) {
        // otherwise work with the main image data
        thumbnailData = event.mainImageData;
    }
    
    UIImage *image = [UIImage imageWithData:thumbnailData];
    // check for size larger than 76px wide (our image size x 2)
    if (image.size.width > 76) {
        float scalingFactor = 76.0/image.size.width;
        CGSize newSize = CGSizeMake(image.size.width * scalingFactor, image.size.height * scalingFactor);
        
        UIGraphicsBeginImageContext( newSize );
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        event.thumbnailData = UIImagePNGRepresentation(newImage);
    }
}

+ (void)purgeOldEvents
{
    NSDate *today = [[NSDate date] aig_TruncatedDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endTime < %@", today];
    
    DLog(@"About to delete %lu expired events from CoreData store.", (unsigned long)[AIGEvent countOfEntitiesWithPredicate:predicate]);
    [AIGEvent deleteAllMatchingPredicate:predicate];
    [[AIGCoreDataManager sharedCoreDataManager] saveContextAndWait:NO];
}


@end
