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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
