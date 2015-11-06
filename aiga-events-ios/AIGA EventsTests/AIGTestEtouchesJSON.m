//
//  AIGTestEtouchesJSON.m
//  AIGA Events
//
//  Created by Dennis Birch on 12/13/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AIGTestEtouchesJSON : XCTestCase

@end

@implementation AIGTestEtouchesJSON

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

- (void)testSerializeEtouchesJSON
{
    NSURL *fileURL = [[NSBundle mainBundle]URLForResource:@"Etouches-Baltimore-events" withExtension:@"json"];
    XCTAssertNotNil(fileURL, @"URL for JSON file should not be nil");
    
    NSData *jsonData = [NSData dataWithContentsOfURL:fileURL];
    XCTAssertNotNil(jsonData, @"JSON data should not be nil");
    
    NSError *error = nil;
    NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error != nil) {
        ALog(@"Error serializing JSON data: %@", [error localizedDescription]);
    }
    XCTAssertNotNil(json, @"JSON object should not be nil");
    
    XCTAssertTrue([json isKindOfClass:[NSArray class]], @"json should be an NSArray");
        
    
}

@end
