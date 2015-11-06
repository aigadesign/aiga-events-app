//
//  AIGDataManager.m
//  AIGA Events
//
//  Created by Dennis Birch on 10/17/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGMockDataManager.h"
#import "AIGChapter+Extensions.h"
#import "AIGEvent+Extensions.h"
#import "AIGCoreDataManager.h"
#import "NSDate+Extensions.h"

@interface AIGMockDataManager ()

@property (nonatomic, assign) BOOL hasLoadedChapterEvents;

@end

@implementation AIGMockDataManager

+ (AIGMockDataManager *)sharedDataManager
{
    static AIGMockDataManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AIGMockDataManager alloc] init];
    });
    
    return sharedManager;
}

- (NSArray *)chapterList
{
    static NSArray *chapters = nil;
    
    if (chapters == nil) {
        NSMutableArray *chapterArray = [NSMutableArray array];
        
        // start making a bunch of chapters
        AIGChapter *chapter = [AIGChapter chapterWithCity:@"Seattle" contactName:@"Aaron Shurts" email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
        chapter = [AIGChapter chapterWithCity:@"San Francisco" contactName:nil email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
        chapter = [AIGChapter chapterWithCity:@"Boston" contactName:nil email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
        chapter = [AIGChapter chapterWithCity:@"Baltimore" contactName:nil email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
        chapter = [AIGChapter chapterWithCity:@"New York" contactName:nil email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
        chapter = [AIGChapter chapterWithCity:@"Los Angeles" contactName:nil email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
        chapter = [AIGChapter chapterWithCity:@"Portland" contactName:nil email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
        chapter = [AIGChapter chapterWithCity:@"Chicago" contactName:nil email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
        chapter = [AIGChapter chapterWithCity:@"Colorado" contactName:nil email:nil eventBriteID:@""];
        [chapterArray addObject:chapter];
        
//        chapter = [AIGChapter chapterWithCity:@"Arizona" contactName:nil email:nil eventBriteID:@""];
//        [chapterArray addObject:chapter];
        
        NSArray *otherChapters = @[@"Alaska", @"Atlanta", @"Austin", @"Birmingham", @"Blue Ridge", @"Brand Central", @"Central Pennsylvania", @"Charlotte", @"Chattanooga", @"Cincinnati", @"Cleveland", @"Connecticut", @"Dallas Fort Worth", @"Detroit", @"Hampton Roads", @"Honolulu", @"Houston", @"Idaho", @"Indianapolis", @"Iowa", @"Jacksonville", @"Kansas City", @"Knoxville", @"Las Vegas", @"Maine", @"Memphis", @"Miami", @"Minnesota", @"Nashville", @"Nebraska", @"New Mexico", @"New Orleans", @"New York, Upstate", @"Oklahoma", @"Orange County", @"Orlando", @"Philadelphia", @"Pittsburgh", @"Raleigh", @"Reno Tahoe", @"Rhode Island", @"Richmond", @"Salt Lake City", @"San Antonio", @"San Diego", @"Santa Barbara", @"South Carolina", @"South Dakota", @"St. Louis", @"Tampa Bay", @"Toledo", @"Triad North Carolina", @"Vermont", @"Washington, DC", @"West Michigan", @"Wichita", @"Wisconsin"];
        
        for (NSString *name in otherChapters) {
            chapter = [AIGChapter chapterWithCity:name contactName:nil email:nil eventBriteID:@""];
            [chapterArray addObject:chapter];
        }
        
        chapters = [chapterArray copy];

        if (!self.hasLoadedChapterEvents) {
            [self loadAllEventsWithChapters:chapterArray];
        }
        
   }
    
    return chapters;
}

- (NSArray *)loadAllEventsWithChapters:(NSArray *)allChapters
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    ZAssert(moc != nil, @"The managed object context must not be nil");
    
    NSMutableArray *events = [NSMutableArray array];
    
    AIGEvent *event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Baltimore" allChapters:allChapters];
    event.eventTitle = @"MEMBERS ONLY: Intro to Letterpress Workshop at Baltimore Print Studios";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:3 hour:11 minute:0];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:3 hour:17 minute:0];
    event.eventDescription = @"<P><STRONG>Dammit Jim, I'm a designer, not a copywriter!</STRONG><BR> On some projects, designers sometimes find themselves being asked to take the place of a professional copywriter. Join <A HREF='http://rebekahcancino.com/'>Rebekah Cancino</A>, Communications Director at Forty and co-organizer of the Phoenix Content Strategy Meetup, as she shares insights and pointers that will help you work more closely with your client in developing better practices for organizing content and writing effective copy whether you end up exercising your own literary skills or handing off to a content specialist.<BR> <BR> <STRONG>Luncha Learne!</STRONG><BR> This lunch presentation series lets you break away from your desk and listen to local design leaders present original perspectives and best practices that will inspire you and your workplace.</P><P><STRONG>Price (includes lunch)</STRONG><BR> $15 - AIGA members<BR> $20 - Ad2Phoenix, AAF, and AMA members<BR> $25 - Non-members</P><P>This workshop is limited to 20 people. In order to accommodate lunch orders, tickets cannot be sold at the door. Registration will close on Tuesday, December 3 at 10 pm.</P>";
    event.address = @"18 W. North Ave., Baltimore";
    event.latitude = @39.31134;
    event.longitude = @-76.617141;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Los Angeles" allChapters:allChapters];
    event.eventTitle = @"Design for Good L.A.: Wrap Up Party";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:8 hour:19 minute:0];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:8 hour:21 minute:0];
    event.eventDescription = @"Five teams of volunteer designers inspired social change for local nonprofits, and you're invited to the big unveil. Join us as we mix, mingle, and celebrate the collaborative efforts performed over 24 hours for the five Los Angeles organizations at the Wrap Up Party.";
    event.venueName = @"General Assembly";
    event.address = @"1520 2nd Street, Santa Monica";
    event.latitude = @34.013049;
    event.longitude = @-118.495329;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Chicago" allChapters:allChapters];
    event.eventTitle = @"Design Thinking II: Natasha Jen";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:21 hour:18 minute:0];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:21 hour:20 minute:0];
    event.eventDescription = @"Design Thinking is AIGA Chicago's biannual lecture series devoted to those defining and driving it.\n\nNatasha Jen was born in Taipei, Taiwan in 1976. She studied graphic design at the School of Visual Arts where she received her BFA with Honors in 2002. Prior to establishing her own studio Njenworks in 2010, Jen worked at Base Design, 2x4, and Stone Yamashita Partners as senior designer and art/creative director. She joined Pentagram as partner in 2012. Jen's work is not bound by the constraints of various media, but developed through contextual exploration. She draws on references from a diverse range of cultural, historical, aesthetic, and technological sources, creating a unique and precise body of work encompassing brand identities, environmental design, multi-scale exhibitions, signage systems, print, motion and interactive graphics.";
    event.venueName = @"Morningstar";
    event.address = @"22 West Washington Street, Chicago";
    event.latitude = @41.883685;
    event.longitude = @-87.628618;
    [events addObject:event];
    
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Chicago" allChapters:allChapters];
    event.eventTitle = @"Member Mixer #4";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:13 hour:18 minute:0];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:13 hour:20 minute:30];
    event.eventDescription = @"Join us Wednesday, November 13, for our 4th—and final—Member Mixer of the year. Catch up and get cozy with your fellow creatives over craft cocktails and hors d'oeuvres at one of the city’s best cocktail bars.";
    event.venueName = @"Barrel House Flat";
    event.address = @"2624 N Lincoln Ave., Chicago";
    event.latitude = @41.929661;
    event.longitude = @-87.654796;
    [events addObject:event];
    
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Los Angeles" allChapters:allChapters];
    event.eventTitle = @"Blueprint: Ethics Game";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:19 hour:18 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:19 hour:21 minute:0];
    event.eventDescription = @"When have we crossed the line in trying to stay in business and increase our profits? Join AIGA/LA and moderator Terry Lee Stone in a live interactive game to explore ethics and design. We'll consider professional behavior in daily business interactions, professional practices in relationship to society, and professional values as a broader framework of moral principles and obligations in life.\n\nThe ETHICS GAME is full of ethically murky scenarios that will have you thinking through what you would do in a variety of tough situations. Be prepared to work through ethical challenges in teams, and participate in the group discussion that follows. Space is limited, so reserve your spot now!";
    event.venueName = @"HUGE Los Angeles";
    event.address = @"6100 Wilshire Blvd, 2nd Floor, Los Angeles";
    event.latitude = @34.063166;
    event.longitude = @-118.361939;
    [events addObject:event];
    
    
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Baltimore" allChapters:allChapters];
    event.eventTitle = @"Converse: Books Designers Love";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:21 hour:18 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:21 hour:20 minute:30];
    event.eventDescription = @"What's your favorite book about design? Bring it to this month's Converse and tell us how it inspired you, improved your career, or opened your eyes to something new. We'll show off some of our favorite publications and talk about the importance of continually learning post-graduation.";
    event.venueName = @"Zen West Roadside Cantina";
    event.address = @"5916 York Road, Baltimore";
    event.latitude = @39.364435;
    event.longitude = @-76.609952;
    [events addObject:event];

    
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Baltimore" allChapters:allChapters];
    event.eventTitle = @"BLEND: Mind the Gap – Communicating with Designers and Developers";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:6 hour:18 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:6 hour:20 minute:30];
    event.eventDescription = @"Does it ever seem as though designers and developers are speaking entirely different languages? Join us as expert web developer John Bintz shares his secrets for improved web production workflows and interdisciplinary harmony.\n\nSince 1995, Bintz has been working on the web. He’s skilled in numerous languages and techniques, has written a web browser, won a Webby award, and is still learning and growing like the rest of us! His unique perspective will help you understand how designers and developers can work together to get the job done.";
    event.venueName = @"Judge's Bench";
    event.address = @"8385 Main Street, Ellicott City, Maryland";
    event.latitude = @39.268452;
    event.longitude = @-76.800701;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Seattle" allChapters:allChapters];
    event.eventTitle = @"Richard Poulin: Graphic Design + Architecture";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:14 hour:18 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:14 hour:21 minute:30];
    event.eventDescription = @"Whether we are aware of it or not, the built environment we experience everyday of our lives relies heavily on graphic design to communicate information and identity as well as influence our overall feelings about place. SEGD and AIGA Seattle are honored to present Richard Poulin to speak about the connection between graphic design and architecture. After the lecture Richard will be signing copies of his book, Graphic Design and Architecture, A 20th Century History: A Guide to Type, Image, Symbol, and Visual Storytelling in the Modern World, the first publication of its kind to provide a comprehensive historical overview of the unique pairing of these two disciplines.\n\nAbout Graphic Design + Architecture:\nOur need to dedicate and consecrate places is clearly the beginning of the integration of graphic design in the built environment. Classical inscriptions, figurative murals, and ornamental surfaces have long been part of architecture and have influenced our understanding of typographic form and graphic style and their visual representation in the built environment. Buildings and public spaces coexist with billboards and signs, patterned and textured facades, and informational and wayfinding signs to effect an overall experience with the public. Graphic design has become integrated with the built environment in shaping not only cities but also the lives of their inhabitants. The built environment we experience in our everyday lives continually relies upon graphic design to communicate information and identity, shape our overall perception and memory of a sense of place, and ultimately enliven, enrich, and humanize our lives.";
    event.venueName = @"UW Savery Hall, Room 260";
    event.latitude = @47.657294;
    event.longitude = @-122.308357;
    [events addObject:event];

    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Seattle" allChapters:allChapters];
    event.eventTitle = @"Creative Mornings: Chase Jarvis";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:8 hour:8 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:8 hour:10 minute:0];
    event.eventDescription = @"Chase Jarvis is well known as a visionary photographer, director, and fine artist with a consistent ambition to break down the barriers between new- and traditional media, fine- and commercial art.\n\nAs a photographic master, Chase has won numerous awards from Prix de la Photographie de Paris, The Advertising Photographers of America, The International Photography Awards, and numerous photographic trade magazine throughout the world. Photo District News (PDN) Magazine called Chase one of the top 30 most influential photographers of the past decade.\n\nEarly in his career, Chase dabbled in filmmaking, directing and producing short films (winning recognition at select film festivals across the country), but this passion was resurrected in 2008 when Chase launched the world’s first HDdSLR for Nikon. As literally the first artist in the world with access to this technology, Chase was propelled into the limelight as a new “indie” directorial figurehead armed with these new cameras and others like it, as well as the creative chops that have helped defined a new era of filmmaking. As such, his career as a Director and Producer of commercials, short films and music videos has exploded in the last 2 years. Whether working on commercial or personal projects, the opportunity to work with some of the best brands of our time–Apple, Starbucks, Nike and others–with multi-platinum artists like Sarah Mclachlan and members of Pearl Jam–Chase has defined an aesthetic that’s all his own.";
    event.venueName = @"EMP Museum";
    event.address = @"325 5th Avenue North, Seattle";
    event.latitude = @47.621901;
    event.longitude = @-122.348526;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Seattle" allChapters:allChapters];
    event.eventTitle = @"Design Lecture Series: Stefan Sagmeister";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:8 hour:18 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:8 hour:20 minute:0];
    event.eventDescription = @"Stefan Sagmeister is a critically acclaimed New York based designer from Vienna. With a focus on concept rather than style, Sagmeister has worked with a wide spectrum of clients such as Lou Reed, The Rolling Stones, HBO and the Guggenheim Museum. In his lectures and art, Sagmeister often explores the subject of personal happiness and balance between work and private life.\n\nArt exhibitions featuring his work have occurred in New York, Philadelphia, Tokyo, Osaka, Seoul, Paris, Zurich, Vienna, Prague, Cologne and Berlin. His work has been profiled in The New York Times, Rolling Stone magazine, Entertainment Tonight, The Late Show with David Letterman and Good Morning America.\n\nDuring his lecture for the Design Lecture Series, Sagmeister will discuss his recent exhibition at the MOCA Los Angeles titled “The Happy Show”: a thematic multidisciplinary exhibition using film, print, graphics, sculpture, and installations to explore the artist’s mood fluctuations through means of mediation, cognitive therapy and pharmaceuticals.";
    event.venueName = @"The Seattle Public Library—Central Branch";
    event.latitude = @47.60706;
    event.longitude = @-122.332899;
    [events addObject:event];
    
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Portland" allChapters:allChapters];
    event.eventTitle = @"AMA PDX – Design Week Discussion";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:12 hour:11 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:12 hour:13 minute:0];
    event.eventDescription = @"Join AMA PDX and Tsilli Pines the founding Co-Director of Design Week Portland, as they discuss what makes Design Week Portland work.\n\nDesign Week Portland celebrates design and engages everyone from the professional practitioner to the greater public with conversations, lectures, tours, exhibits, and more. Two years ago, the festival was launched with no infrastructure and little funding. It succeeded due to the strength of its community-driven approach. Armed with a scalable model and the right people in the room, the DWP team quickly iterated a full-blown festival within five months. Portland proved to be fertile ground for an explosion of creative content, and the timing was right to gain notice outside city limits.";
//    event.venueName = @"Bridgeport Brewery";
    event.address = @"1318 NW Northrup St, Portland";
    event.latitude = @45.531568;
    event.longitude = @-122.684617;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Portland" allChapters:allChapters];
    event.eventTitle = @"dMob: 10th Anniversary Party at Vendetta";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:13 hour:18 minute:0];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:13 hour:21 minute:0];
    event.eventDescription = @"Ten years has gone by and so much has changed – W has been replaced by Obama, the Concorde’s been retired, and Facebook is public. What hasn’t changed? AIGA’s Portland’s monthly networking extravaganza, also known as dMob. For a decade now, we still gather every month and ask each other, “Can I buy you a drink?”\n\nThis month we’ll be at Vendetta, where you can enjoy a beer or strong cocktail, play some shuffleboard, and reminisce about the good old days when you had to walk two blocks to the nearest Starbucks. Help us celebrate with a piece of birthday cake while admiring photos of your fellow creatives in a very special big screen slide show. This is a dMob not to be missed!\n\nThe dMob Concept\nThis is our monthly gathering for the entire Portland design community. Social interaction and networking is at the core of this AIGA Portland event – we encourage discussion, business development, and work to help foster a more dynamic design community here in Portland. Plus, with such a plethora of independent breweries, our choice of venues and beverages is expansive.";
    event.venueName = @"Vendetta";
    event.address = @"4306 N Williams Ave, Portland";
    event.latitude = @45.554914;
    event.longitude = @-122.666529;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"New York" allChapters:allChapters];
    event.eventTitle = @"BREAKFAST CLUB: WILDE TEACHING";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:23 hour:8 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:23 hour:9 minute:30];
    event.eventDescription = @"You’re a practicing designer and you teach, too. Maybe you’ve never been formally trained in design education, but you feel passionate about teaching and are always looking for ways to be a better instructor and mentor.\n\nJoin visionary Richard Wilde, Chairman of the world-famous Design and Advertising Department at the School of Visual Arts, to talk about evolving from being a good to great design educator. Richard will speak to strategies for making inspiring syllabi and what goes into creating optimal conditions for motivating students and yourself. More advanced topics include navigating adjunct teaching in NYC, how to graduate to full time professorship, what he looks for in a new hire and the impact of new technology on design education.";
    event.venueName = @"SVA Branding Studio";
    event.latitude = @40.740039;
    event.longitude = @-73.981775;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"New York" allChapters:allChapters];
    event.eventTitle = @"MIX: DESIGNERS + DRINKS = _________";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:6 hour:19 minute:0];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:6 hour:21 minute:0];
    event.eventDescription = @"The first Wednesday of every month, AIGA/NY invites members and their guest to enjoy two happy hours at The Wooly, a historic private bar in the basement of the Woolworth building. A different designer or studio will host each event, on November 6th join SoHo brand consultancy DIA for live music, video projection, two-for-one drink specials, and more!\nDIA is a brand consultancy based in SOHO. Their work spans the creative spectrum from graphic design and typography to film, motion graphics and music.";
    event.venueName = @"The Wooly";
    event.address = @"11 Barclay Street, New York";
    event.latitude = @40.712435;
    event.longitude = @-74.008575;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"New York" allChapters:allChapters];
    event.eventTitle = @"FONTS FOR THE WEB WITH JONATHAN HOEFLER";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:14 hour:18 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:14 hour:20 minute:30];
    event.eventDescription = @"Is fine typography on the web at long last a reality? This summer, distinguished type designers Hoefler & Frere-Jones launched Cloud.typography, which brings a new generation of tools to designers, and sets a new standard for readability on the screen.\n\nJoin Jonathan Hoefler, recipient of the 2013 AIGA Medal, on a tour of H&FJ’s four-year project to bring fine typography to the web. You’ll see how H&FJ adapted its library of famous typefaces for the web, learn some new ways of looking at type that are essential to the cross-disciplinary designer, and see how the web can be a truly great medium for elegant, articulate, and expressive typography.";
    event.venueName = @"Tishman Auditorium - Parsons";
    event.address = @"66 West 12th Street, New York";
    event.latitude = @40.735649;
    event.longitude = @-73.997299;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Colorado" allChapters:allChapters];
    event.eventTitle = @"Design Slam";
    event.startTime = [NSDate aig_DateWithYear:2013 month:10 date:26 hour:11 minute:00];
    event.endTime = [NSDate aig_DateWithYear:2013 month:10 date:26 hour:15 minute:00];
    event.eventDescription = @"If you are in the creative industry and enjoy riding bikes, taking photos, drinking beers, being awesome, and socializing, this event is for you!\n\nTerminal Velocity is on like Donkey Kong for the second year in a row. Imagine you and your friends setting out on a citywide bike tour for the sole purpose of capturing Denver’s found typography, then enjoying a few drinks with the competition afterwards. Sound good? Great!\n\nThe Challenge: Create a unique alphabet built from photos of found typography.\n\nThe Reward: Fame, glory, and maybe a little $omething else.";
    [events addObject:event];
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Arizona" allChapters:allChapters];
    event.eventTitle = @"Branding Your Brew – Tucson 20X20";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:7 hour:18 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:7 hour:21 minute:00];
    event.eventDescription = @"Join AIGA Arizona and Tucson Young Professionals for a hoppy celebration of Tucson’s craft brew industry.\n\nSample beers and get a taste of the business through quick, fun, PechaKucha-style presentations from Dragoon Brewing Company, Ten Fifty-Five Brewing, Borderlands Brewing Company, Catalina Brewing Company, Sentinel Peak Brewing, and Tap & Bottle.\n\nSpace is limited, so click the button below and reserve your seat today!";
    event.venueName = @"Thunder Canyon Brewery Downtown";
    event.address = @"220 E. Broadway Boulevard, Tucson";
    event.latitude = @32.221025;
    event.longitude = @-110.966641;
    [events addObject:event];

    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"Arizona" allChapters:allChapters];
    event.eventTitle = @"Special Screening: Design is One";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:21 hour:19 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:21 hour:21 minute:00];
    event.eventDescription = @"Two of the world’s most influential designers, Lella and Massimo Vignelli’s work covers such a broad spectrum that one could say they are known by everyone, even by those who don’t know their names. Adhering to self-proclaimed motto, “If you can’t find it, design it,” their achievements in industrial and product design, graphic and publication design, corporate identity, architectural graphics, and exhibition, interior, and furniture design have earned worldwide respect and numerous international awards for over 40 years.\n\nAfter Massimo brought the Helvetica typeface to America in 1965, he and Lella moved on to a diverse array of projects, including New York’s subway signage and maps; the interior of Saint Peter’s Church at Citicorp Center; Venini lamps; Heller dinnerware; furniture for Poltrona Frau; and branding for Knoll International, Bloomingdales, Saks Fifth Avenue, Ford and American Airlines.  \n\nLuminaries from the world of design – from architects Richard Meier and Peter Eisenman to graphic designers Milton Glaser, Michael Bierut, and Jessica Helfand – bring us into the Vignellis’ world, capturing their intelligence and creativity, as well as their humanity, warmth, and humor.";
    event.venueName = @"FilmBar";
    event.address = @"815 N. 2nd Street, Phoenix";
    event.latitude = @33.457349;
    event.longitude = @-112.071031;
    [events addObject:event];

    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"San Francisco" allChapters:allChapters];
    event.eventTitle = @"What the hell is experience design anyway? — an evening with Kevin Farnham of Method";
    event.startTime = [NSDate aig_DateWithYear:2013 month:10 date:24 hour:18 minute:30];
    event.endTime = [NSDate aig_DateWithYear:2013 month:10 date:24 hour:21 minute:00];
    event.eventDescription = @"In a connected world, brands are defined by the product and service experiences they deliver, not the images they advertise. Method is a diverse and dynamic global team, working collaboratively to challenge ourselves and our clients to create more engaging integrated brand, product and service experiences. Our clients are among the world’s most prominent and progressive brands, and include Barclays, Google, Nordstrom, LG, MoMA, Time Warner Cable, Steelcase, and Microsoft.\n\nEveryone is welcome. And it’s free.";
    event.venueName = @"Academy of Art University’s Morgan Auditorium";
    event.address = @"491 Post Street, San Francisco";
    event.latitude = @37.788081;
    event.longitude = @-122.409691;
    [events addObject:event];
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"San Francisco" allChapters:allChapters];
    event.eventTitle = @"VisualMedia 013 Conference + Expo: Expressions";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:6 hour:8 minute:00];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:6 hour:20 minute:00];
    event.eventDescription = @"VisualMedia 013 is a conference for marketers, designers, creative directors, printers, media buyers, and for anyone in the visual media industry who earns a living by providing creative services to their customers. With special focus on the latest design & marketing trends & technologies, VM013 Expressions is packed with opportunities to learn, grow, play, and connect. Featuring two keynotes, 12 seminars with three tracks on the hottest topics by leading industry-professionals, an evening networking party with hors d’oeuvres and beverages, prizes, the day promises to inspire the experienced professional as well as the up-and-coming.";
    event.venueName = @"Contemporary Jewish Museum";
    event.address = @"736 Mission Street, San Francisco";
    event.latitude = @37.786157;
    event.longitude = @-122.403372;
    [events addObject:event];
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"San Francisco" allChapters:allChapters];
    event.eventTitle = @"Designer as Founder: YouTube Christina Brodbeck";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:1 hour:18 minute:00];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:1 hour:20 minute:00];
    event.eventDescription = @"Designer as Founder, presented by AIGA San Francisco in collaboration with PARISOMA, is a series of conversations with successful designers-turned-founders. The next in our series features Christina Brodbeck, founding team member, first UI designer and lead mobile designer at YouTube, who is now co-founder and CEO of theicebreak. We’ll hear stories, challenges and triumphs about her leap from the role of designer on a creative team to a founding role in creating a new business like no other.\n\nNow more than ever, designers are being asked to take on the role of thought leader, technologist and creator of new innovative products. The goal of this series is to have a concrete conversation about what it takes to make ideas happen in this new environment. Join us for an action-oriented discussion with moderator Philip Wood and some of the most inspiring designer founders in the San Francisco Bay Area.";
    event.venueName = @"Parismona";
    event.address = @"169 11th Street, San Francisco";
    event.latitude = @37.773844;
    event.longitude = @-122.415796;
    [events addObject:event];
    
    event = [NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:moc];
    event.chapter = [self chapterWithCityName:@"San Francisco" allChapters:allChapters];
    event.eventTitle = @"ROADMAP: The Intersection of Design and Experience Conference";
    event.startTime = [NSDate aig_DateWithYear:2013 month:11 date:6 hour:9 minute:00];
    event.endTime = [NSDate aig_DateWithYear:2013 month:11 date:6 hour:18 minute:00];
    event.eventDescription = @"How we interact and engage with the world and each other is being influenced by connectivity and technology. In this always-changing data-rich environment, experience design has become as important as the technology itself.\n\nGigaOM’s third annual RoadMap conference is a two-day experience design conference for the tech industry, featuring the leading experience designers, technology innovators, and designer founders that are building the next-generation of connected human-centered products and using design to disrupt industries.";
    event.venueName = @"Yerba Buena Center for the Arts";
    event.address = @"701 Mission Street, San Francisco";
    event.latitude = @37.785987;
    event.longitude = @-122.402353;
    [events addObject:event];
    
    self.hasLoadedChapterEvents = YES;
    
     return [events copy];
}

- (NSArray *)loadAllEvents
{
    NSArray *allChapters = [self chapterList];
    return [self loadAllEventsWithChapters:allChapters];
}

- (AIGChapter *)chapterWithCityName:(NSString *)city allChapters:(NSArray *)allChapters
{
    __block AIGChapter *result;
    [allChapters enumerateObjectsUsingBlock:^(AIGChapter *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.city isEqualToString:city]) {
            result = obj;
            *stop = YES;
        }
    }];
    
    return result;
}


@end
