//
//  AIGCoreDataManager.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/18/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGCoreDataManager.h"
#import "AIGChapter.h"
#import "AIGEvent+Extensions.h"
//#import "AIGMockDataManager.h"

@interface AIGCoreDataManager ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *privateContext;

@end

@implementation AIGCoreDataManager

+ (instancetype)sharedCoreDataManager
{
	static AIGCoreDataManager *sharedManager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[[self class] alloc] init];
	});
	
	return sharedManager;
}

+ (instancetype)sharedCoreDataTestManager
{
	static AIGCoreDataManager *sharedManager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[[self class] alloc] initTestInstance];
	});
	
	return sharedManager;
}

- (void)saveContextAndWait:(BOOL)wait
{
    if (wait) {
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    else
    {
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (error) {
                ZAssert(!error, @"Error saving MOC: %@\n%@",
                        [error localizedDescription], [error userInfo]);
            }
        }];
    }
}

- (instancetype)init
{
	self = [super init];
	if(!self) {
        return nil;
    }
	
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"AIGFeedData.sqlite"];

    _mainManagedObjectContext = [NSManagedObjectContext MR_defaultContext];
    _privateContext = [NSManagedObjectContext MR_context];
	return self;
}


- (instancetype)initTestInstance
{
	self = [super init];
	if(!self) {
        return nil;
    }
	
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	
    NSDictionary *options = @{NSPersistentStoreFileProtectionKey: NSFileProtectionComplete,
                              NSMigratePersistentStoresAutomaticallyOption:@YES};
    NSError *error = nil;
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
																		configuration:nil
																				  URL:nil
																			  options:options
																				error:&error];
    if (store == nil) {
        NSLog(@"Error adding persistent store. Error %@",error);
    }
	
    // create a private MOC directly connected to persistent store
    NSUInteger type = NSPrivateQueueConcurrencyType;
    NSManagedObjectContext *private = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    [private setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    // create a MOC for
    type = NSMainQueueConcurrencyType;
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    [moc setParentContext:private];
    self.privateContext = private;
    
    self.mainManagedObjectContext = moc;
    
	return self;
}

-(void)initialize
{
    //no op
    //necessary to setup core data stack
}

-(void)cleanup
{
    [MagicalRecord cleanUp];
}
@end
