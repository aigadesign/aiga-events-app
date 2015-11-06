//
//  AIGTestEventbriteJSON.m
//  AIGA Events
//
//  Created by Dennis Birch on 12/12/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AIGEvent+Extensions.h"

@interface AIGTestEventbriteJSON : XCTestCase

@end

@implementation AIGTestEventbriteJSON

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSerializeEventbriteJSON
{
    NSURL *fileURL = [[NSBundle mainBundle]URLForResource:@"Eventbrites-Seattle-events" withExtension:@"json"];
    XCTAssertNotNil(fileURL, @"URL for JSON file should not be nil");
    
    NSData *jsonData = [NSData dataWithContentsOfURL:fileURL];
    XCTAssertNotNil(jsonData, @"JSON data should not be nil");
    
    NSError *error = nil;
    NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error != nil) {
        ALog(@"Error serializing JSON data: %@", [error localizedDescription]);
    }
    XCTAssertNotNil(json, @"JSON object should not be nil");
    
    XCTAssertTrue([json isKindOfClass:[NSDictionary class]], @"json should be an NSDictionary");
    
    NSDictionary *dict = (NSDictionary *)json;
    NSArray *events = dict[@"events"];
    
    XCTAssertTrue([events isKindOfClass:[NSArray class]], @"'events' should be an NSArray");
    
    
}



@end
