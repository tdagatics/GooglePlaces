//
//  ViewController.h
//  GooglePlaces
//
//  Created by Anthony Dagati on 11/2/14.
//  Copyright (c) 2014 Black Rail Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#define kGOOGLE_API_KEY @"AIzaSyAK-11MCB6KfW6RRb_qXo_DKpaAyF1ybD4"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

{
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

