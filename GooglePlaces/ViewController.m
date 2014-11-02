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
}



#pragma mark - MKMapViewDelegate Methods
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 1000, 1000);
    
    [mapView setRegion:region animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
