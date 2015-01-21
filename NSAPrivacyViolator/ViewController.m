//
//  ViewController.m
//  NSAPrivacyViolator
//
//  Created by Diego Cichello on 1/21/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property CLLocationManager *myLocationManager;
@property CLLocation *reverseGeocode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myLocationManager = [CLLocationManager new];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self;


}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error :%@",error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if(location.verticalAccuracy < 1000 && location.horizontalAccuracy <1000)
        {
            self.myTextView.text = @"Location found reverse geocode";
            [self reverseGeocode:location];
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void) reverseGeocode:(CLLocation *)location
{
    NSLog(@"Start pretty function in: %s", __PRETTY_FUNCTION__);
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@ \n%@", placemark.subThoroughfare,placemark.thoroughfare,placemark.locality];

        self.myTextView.text =[NSString stringWithFormat:@"Found you: @%@",address];
        [self findJailNear:placemark.location];
    }];
}

- (void) findJailNear: (CLLocation *) location
{
    NSLog(@"Start pretty function in: %s", __PRETTY_FUNCTION__);
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"Prison";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake (1,1));

    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        MKMapItem  *mapItem = mapItems.firstObject;
        self.myTextView.text = [NSString stringWithFormat:@"You should go to: %@",mapItem.name];
        [self getDirectionsTo:mapItem];

    }];



}

- (void)getDirectionsTo:(MKMapItem *)destinationItem
{
    NSLog(@"Start pretty function in: %s", __PRETTY_FUNCTION__);
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationItem;


    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;


        int x =1;
        NSMutableString *directionsString = [NSMutableString string];
        for (MKRouteStep *step in route.steps)
        {
            [directionsString appendFormat:@"%d: %@\n", x, step.instructions];
            x++;
        }


        self.myTextView.text = directionsString;
    }];
}


- (IBAction)startViolatingPrivacy:(id)sender {


    [self.myLocationManager startUpdatingLocation];
    self.myTextView.text = @"Location you";
}


@end
