
#define   kUseMockData    0

static NSString *ChapterSelectionsChangedNotification = @"ChapterSelectionsChangedNotification";
static NSString *ChapterSelectionsKey = @"ChapterSelectionsKey";
static NSString *ChaptersDoneDownloadingNotification = @"ChaptersDoneDownloadingNotification";
static NSString *ImageDownloadCompletionNotification = @"ImageDownloadCompletionNotification";
static NSString *EventsDoneDownloadingNotification = @"EventsDoneDownloadingNotification";

static NSString *LastEventBriteAPIKey = @"LastEventBriteAPIKey";
static NSString *LastEtouchesAPIKey = @"LastEtouchesAPIKey";

static NSString *NETWORKUNAVALAIBLEWARNING = @"You are not connected to the Internet.\nCheck your settings and try again.";

static NSString *HASDISPLAYEDINITIALCHAPTERSLIST = @"HasDisplayedInitialChaptersList";
static NSString *HASDISPLAYEDGETSTARTEDVIEW = @"HasDisplayedGetStartedView";

#ifdef DEBUG
#define MCRelease(x) [x release]
#define DLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) {NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__]);[[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__];}
#else
#define MCRelease(x) [x release], x = nil
#define DLog(...) do { } while (0)
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define ALog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define ZAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)
