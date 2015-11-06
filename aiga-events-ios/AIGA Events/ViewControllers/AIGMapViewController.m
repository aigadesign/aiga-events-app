//
//  AIGMapViewController.m
//  AIGA Events
//
//  Created by Dennis Birch on 11/1/13.
//  Copyright (c) 2013 Deloitte Digital. All rights reserved.
//

#import "AIGMapViewController.h"
#import "AIGEventLocation.h"
@import MapKit;
@import AddressBook;

@interface AIGMapViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKMapCamera *camera;

@end

@implementation AIGMapViewController

static NSString *LastMapViewDataKey = @"LastMapViewData";
static NSString *LastMapViewVenueKey = @"LastMapViewVenue";
static NSString *LastMapViewLatitudeKey = @"LastMapViewLatitude";
static NSString *LastMapViewLongitudeKey = @"LastMapViewLongitude";
static NSString *LastMapViewAltitudeKey = @"LastMapViewAltitude";
static NSString *LastMapViewPitchKey = @"LastMapViewPitch";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D coordinate;
    NSDictionary *lastViewData = [[NSUserDefaults standardUserDefaults] objectForKey:LastMapViewDataKey];

    // see if we're viewing the same map as last use and restore view
    if ([lastViewData[LastMapViewVenueKey] isEqualToString:self.venueLocation.title]) {
        NSNumber *latitude = lastViewData[LastMapViewLatitudeKey];
        NSNumber *longitude = lastViewData[LastMapViewLongitudeKey];
        NSNumber *altitude = lastViewData[LastMapViewAltitudeKey];
        NSNumber *pitch = lastViewData[LastMapViewPitchKey];
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
        self.camera = [MKMapCamera camera];
        self.camera.centerCoordinate = center;
        self.camera.altitude = altitude.floatValue;
        self.camera.pitch = pitch.floatValue;
    } else {
        // if not the last venue viewed, start with a default view
        coordinate = self.venueLocation.coordinate;
        CLLocationCoordinate2D eyeCoordinate = self.venueLocation.coordinate;
        eyeCoordinate.latitude -= .05;
        self.camera = [MKMapCamera cameraLookingAtCenterCoordinate:coordinate fromEyeCoordinate:eyeCoordinate eyeAltitude:100];
    }


    self.mapView.camera = self.camera;
    self.mapView.showsBuildings = YES;
    
    self.mapView.showsUserLocation = YES;
    
    [self.mapView addAnnotation:self.venueLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // save map viewing data
    MKMapCamera *camera = self.mapView.camera;
    NSDictionary *mapInfo = @{LastMapViewVenueKey : self.venueLocation.title,
                              LastMapViewLatitudeKey : @(camera.centerCoordinate.latitude),
                              LastMapViewLongitudeKey : @(camera.centerCoordinate.longitude),
                              LastMapViewAltitudeKey : @(camera.altitude),
                              LastMapViewPitchKey : @(camera.pitch)
                              };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:mapInfo forKey:LastMapViewDataKey];
    [defaults synchronize];
}

- (IBAction)directionsButtonTouched:(id)sender
{
    NSDictionary *launchOptions = @{MKLaunchOptionsMapSpanKey : [NSValue valueWithMKCoordinateSpan:self.mapView.region.span],
                                    MKLaunchOptionsMapCenterKey: [NSValue valueWithMKCoordinate:self.mapView.region.center],
                                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving};
    NSString *geoAddress = self.venueLocation.subtitle;
    __weak __typeof(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:geoAddress
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     MKPlacemark *placemark;
                     MKMapItem *mapItem;

                     if (error) {
                         //geocoding failed, just use the lat/lon we have
                         NSDictionary *addressDict = @{(NSString *)kABPersonAddressStreetKey: self.venueLocation.subtitle};
                         placemark = [[MKPlacemark alloc] initWithCoordinate:self.venueLocation.coordinate addressDictionary:addressDict];
                         mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:weakSelf.venueLocation.title];
                     }
                     else {
                         // Convert the CLPlacemark to an MKPlacemark
                         CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                         placemark = [[MKPlacemark alloc]
                                      initWithCoordinate:geocodedPlacemark.location.coordinate
                                      addressDictionary:geocodedPlacemark.addressDictionary];

                         mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:geocodedPlacemark.name];
                         if (!geocodedPlacemark.name) {
                             [mapItem setName:weakSelf.venueLocation.title];
                         }
                     }

                     MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                     [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                 }];
}

-(IBAction)doneButtonTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Annotation"];
    if (pinView == nil) {
        MKPinAnnotationView *mapPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        mapPin.animatesDrop = YES;
        pinView = mapPin;
        pinView.canShowCallout = YES;
 }
    
    return pinView;
}

@end
