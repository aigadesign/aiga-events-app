//
//  AIGChapter+Extensions.m
//  AIGA Events
//
//  Created by George McCarroll on 1/7/14.
//  Copyright (c) 2014 Deloitte Digital. All rights reserved.
//

#import "AIGChapter+Extensions.h"
#import "AIGEvent+Extensions.h"
#import "AIGUser.h"
#import "AIGCoreDataManager.h"

@implementation AIGChapter (Extensions)

+ (instancetype)chapterWithCity:(NSString *)city contactName:(NSString *)contact email:(NSString *)email eventBriteID:(NSString *)eventBriteID
{
    // a method to load a chapter for use as Mock data object
    AIGChapter *chapter = [AIGChapter createEntity];
    
    if (chapter) {
        chapter.contactName = contact;
        chapter.city = city;
        chapter.email = email;
        chapter.eventBriteOrg = eventBriteID;
    }
    
    return  chapter;
}

+ (AIGChapter *)chapterForCity:(NSString *)city
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kChapterEntityName];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city = %@", city];
    request.predicate = predicate;
    
    return [AIGChapter findFirstWithPredicate:predicate];
}

+ (NSArray *)namesForChapters:(NSArray *)chapters
{
    NSMutableArray *outArray = [NSMutableArray arrayWithCapacity:chapters.count];
    for (NSString *chapter in chapters) {
        [outArray addObject:chapter];
    }
    
    return [outArray copy];
}

- (NSArray *)eventsForChapter
{
    NSArray *allObjects = [AIGEvent eventsForChapter:self];
    return [allObjects sortedArrayUsingComparator:^NSComparisonResult(AIGEvent *obj1, AIGEvent *obj2) {
        return [obj1.startTime compare:obj2.startTime];
    }];
    
    return allObjects;
}

-(NSUInteger)countOfEventsForChapter
{
    return [AIGEvent countOfEventsForChapter:self];
}

+ (void)importChapters:(NSDictionary *)allChaptersDict
{
    // handle a dictionary of dictionaries containing eventBriteID, and eTouchesID
    NSArray *keys = [allChaptersDict allKeys];
    for (NSString *chapterName in keys) {
        NSDictionary *oneChapterDict = allChaptersDict[chapterName];
        NSString *eventBriteID = oneChapterDict[kEventBriteIDKey];
        NSNumber *eTouchesID = oneChapterDict[kETouchesIDKey];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city = %@", chapterName];
        
        AIGChapter *chapter = [AIGChapter findFirstWithPredicate:predicate];
        if (chapter == nil) {
            chapter = [AIGChapter createEntity];
            chapter.city = chapterName;
        } else {
            chapter.eventBriteOrg = eventBriteID;
            if (![eTouchesID isEqual:@(NSNotFound)]) {
                chapter.eTouchesID = [eTouchesID stringValue];
            }
        }
    }
    
    [[AIGCoreDataManager sharedCoreDataManager] saveContextAndWait:YES];
}

- (AIGEvent *)eventWithID:(NSNumber *)eventID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventBriteID = %@ OR eTouchesID = %@", eventID, eventID];
    NSSet *eventSet = [self.events filteredSetUsingPredicate:predicate];
    return [eventSet anyObject];
}

- (void)setSelected:(BOOL)isSelected
{
    [self willChangeValueForKey:@"selected"];
    [self setPrimitiveValue:@(isSelected) forKey:@"selected"];
    [self didChangeValueForKey:@"selected"];
    if (!isSelected) {
        // delete events to free up memory
        self.events = [NSSet new];
    }
}

+ (NSArray *)allChapterNames
{
    NSError *error = nil;
    NSArray *result = [AIGChapter findAllSortedBy:@"city" ascending:YES];
    if (result == nil) {
        ALog(@"Error fetching chapters: %@",[error localizedDescription]);
        return nil;
    }
    
    NSMutableArray *allChapters = [NSMutableArray arrayWithCapacity:result.count];
    for (AIGChapter *chapter in result) {
        [allChapters addObject:chapter.city];
    }
    
    return allChapters;
}

+ (NSArray *)selectedChapters
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == YES"];
    NSArray *selectedChapters = [self findAllWithPredicate:predicate];
    
    return selectedChapters;
}

+(NSArray *)sortedChapters
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == YES"];
    NSArray *selectedChapters = [self findAllSortedBy:@"city" ascending:YES withPredicate:predicate];
    
    return selectedChapters;
}

+(NSDictionary *)chaptersDict
{
    __block NSArray *sortedChapters = [self findAllSortedBy:@"city" ascending:YES];
    __block NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (sortedChapters) {
        [sortedChapters enumerateObjectsUsingBlock:^(AIGChapter *chapter, NSUInteger idx, BOOL *stop) {
            
            NSString *initial = [[chapter city] substringToIndex:1];
            NSMutableArray *chaptersArray = dict[initial];
            
            if (chaptersArray == nil) {
                chaptersArray = [NSMutableArray new];
            }
            
            [chaptersArray addObject:chapter];
            dict[initial] = chaptersArray;
        }];
    }
    
    return [dict copy];
}

+(NSArray *)sortedChapterInitials
{
    NSArray *keys = [[[self chaptersDict] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)obj1 compare:obj2 options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
    }];
    
    return keys;
}
@end
