//
//  AIGChapterDownloader.h
//  AIGA Events
//
//  Created by Dennis Birch on 11/20/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define kParseAppID    @"NqlLy5KEvDy5V7p0FSv3sKu1b5WdAcegqvg07Khn"
//#define kParseClientID  @"yGJvw6w1GyA0HdsMyjz4K7TO9hGdUVmchXJvIhvD"

#define kParseAppID    @"4Utrt6Ok4pkIsiAJT95ih0sFtZjtXz1HKEcoS2ug"
#define kParseClientID  @"xuAVpQYkuTnjLoNx1VUe0O1G25oK5OPpnqh4SJWX"

static NSString *LastChapterDownloadDate = @"LastChapterDownload";
static NSString *ChapterDownloadErrorDomain = @"ChapterDownloadErrorDomain";

typedef NS_ENUM(NSInteger, ChapterDownloadError) {
	ChapterDownloadErrorExceeded24HourMaximum = 1,
    ChapterDownloadErrorTooFrequentAttempts,
};

@interface AIGChapterDownloader : NSObject

@property (nonatomic, strong, readonly) NSDictionary *chaptersDictionary;

- (void)downloadChaptersWithCompletionHandler:(void (^)(NSDictionary *responseDict, NSError *error))completionHandler;

@end
