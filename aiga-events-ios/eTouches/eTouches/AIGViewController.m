//
//  AIGViewController.m
//  eTouches
//
//  Created by Dennis Birch on 12/6/13.
//  Copyright (c) 2013 DeloitteDigital. All rights reserved.
//

#import "AIGViewController.h"
#import "AIGETouchesDownloadManager.h"

@interface AIGViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, weak) IBOutlet UITextField *numberField;

@end

@implementation AIGViewController

- (void)setEvent:(NSString *)event
{
    _event = event;
    self.textView.text = event;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)fetchEvents:(id)sender
{
    
    [[AIGETouchesDownloadManager sharedEventDataDownloadManager] downloadEventListForOrganizer:self.numberField.text
                                                                                     startDate:[NSDate date] endDate:[NSDate date]
                                                                             completionHandler:
     ^(NSArray *responseArray, NSError *error) {
         
         NSLog(@"ResponseDict: %@", responseArray);
     }];
    
    //    [[AIGeTouchesDownloadManager sharedEventDataDownloadManager] downloadFoldersWithCompletionHandler:^(NSArray *responseArray, NSError *error) {
    //        [self parseFoldersArray:responseArray];
    //    }];
}


// NOTE: TRY GETEVENT WITH EVENTID AS PARAMETER FOR DETAILS

- (void)parseFoldersArray:(NSArray *)array
{
    NSString *result = @"";
    
    for (NSDictionary *folder in array) {
        NSNumber *parentID = folder[@"parentid"];
        if (parentID.integerValue > 0) {
            NSString *folderInfo = [NSString stringWithFormat:@"%@,%@\n",folder[@"name"], folder[@"folderid"]];
            result =[result stringByAppendingString: folderInfo];
        }
    }
    
    NSLog(@"\n\n%@", result);
}

@end
