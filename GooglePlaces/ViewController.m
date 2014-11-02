//
//  ViewController.m
//  GooglePlaces
//
//  Created by Anthony Dagati on 11/2/14.
//  Copyright (c) 2014 Black Rail Capital. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Make this controller the delegate for the map view
    self.mapView.delegate = self;
    
    // Ensure that you can view your own location the mapview
    self.mapView.showsUserLocation = YES;
    
    // Instantiate a location object
    locationManager = [[CLLocationManager alloc] init];
    
    // Make this controller the delegate for the location manager
    [locationManager setDelegate:self];
    
    // Set some parameters for the location object
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (IBAction)toolBarButtonPressed:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    NSString *buttonTitle = [button.title lowercaseString];
    
    // Use this title text to build the URL query and get the data from Google
    [self queryGooglePlaces:buttonTitle];
}

-(void)queryGooglePlaces:(NSString *)googleType {
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", currentCentre.latitude, currentCentre.longitude, [NSString stringWithFormat:@"%i", currenDist], googleType, kGOOGLE_API_KEY];

    // Formulate the string as an URL object
    NSURL *googleRequestURL = [NSURL URLWithString:url];
    
    // Retrieve the results of the URL
    dispatch_async(kBgQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        
    });
}

-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    // The results from Google will be an array obtained from the NSDictionary object with the key "results"
    NSArray *places = [json objectForKey:@"results"];
    
    // Write out the data to the console.
    NSLog(@"Google Data: %@", places);
    [self plotPositions:places];
    
}


#pragma mark - MKMapViewDelegate Methods
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 1000, 1000);
    
    [mapView setRegion:region animated:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // Get the east and west points on the map so you can calculate the distance (zoom level) of the current map view.
    MKMapRect mRect= self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    // Set your current distance instance variable
    currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    // Set your current center point on the map instance variable
    currentCentre = self.mapView.centerCoordinate;
}

-(void)plotPositions:(NSArray *)data {
    // 1 - Remove any existing custom annotations but not the user location blue dot
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            [_mapView removeAnnotation:annotation];
        }
    }
    // 2 - Loop through the array of placres returned from the Google API.
    for (int i = 0; i<[data count]; i++) {
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary *place = [data objectAtIndex:i];
        // 3 - There is a specific NSDictionary object that gives us the location info
        NSDictionary *geo = [place objectForKey:@"geometry"];
        // Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        // 4 - Get your name and address info for adding to a pin.
        NSString *name = [place objectForKey:@"name"];
        NSString *vicinity = [place objectForKey:@"vicinity"];
        // Create a special variable to hold this coordinate info
        CLLocationCoordinate2D placeCoord;
        // Set the lat and long.
        placeCoord.latitude = [[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude = [[loc objectForKey:@"lng"] doubleValue];
        // 5 - Create a new annotation
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:vicinity coordinate:placeCoord];
        [_mapView addAnnotation:placeObject];
        
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Define your reuse identifier.
    static NSString *identifier = @"MapPoint";
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        return annotationView;
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
