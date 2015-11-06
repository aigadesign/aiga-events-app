//
//  AIGChapterViewController.m
//  eTouches
//
//  Created by Dennis Birch on 12/9/13.
//  Copyright (c) 2013 DeloitteDigital. All rights reserved.
//

#import "AIGChapterViewController.h"
#import "AIGViewController.h"
#import "AIGETouchesDownloadManager.h"

@interface AIGChapterViewController ()

@property (nonatomic, strong) NSDictionary *chapterDict;

@end

@implementation AIGChapterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *url = [bundle URLForResource:@"ETouchesChapters" withExtension:@"txt"];
    NSError *error = nil;
    NSString *chapterList = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    NSArray *lines = [chapterList componentsSeparatedByString:@"\n"];
    NSMutableDictionary *chapters = [NSMutableDictionary dictionary];
    
    for (NSString *line in lines) {
        NSArray *fields = [line componentsSeparatedByString:@"\t"];
        if (fields.count > 1) {
            chapters[fields[0]] = fields[1];
        }
    }
    
    self.chapterDict = [chapters copy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chapterDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.chapterDict allKeys][indexPath.row];
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EventDetailSegue"]) {
        AIGViewController *vc = segue.destinationViewController;
        NSInteger selection = [self.tableView indexPathForSelectedRow].row;
        NSString *chapter = [self.chapterDict allKeys][selection];
        NSString *folderID = self.chapterDict[chapter];
        [[AIGETouchesDownloadManager sharedEventDataDownloadManager]downloadEventListForOrganizer:folderID startDate:nil endDate:nil completionHandler:^(NSArray *responseArray, NSError *error) {
            vc.event = responseArray.description;
        }];
    }
}

@end
