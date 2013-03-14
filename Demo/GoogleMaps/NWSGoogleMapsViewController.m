//
//  NWSGoogleMapsViewController.m
//  Spaghetti
//
//  Copyright (c) 2013 noodlewerk. All rights reserved.
//

#import "NWSGoogleMapsViewController.h"
#import <MapKit/MapKit.h>
#import "Spaghetti.h"


@interface NWSGoogleMapsResult : NSObject
@property (nonatomic, copy) NSString *formatted;
@property (nonatomic, strong) NSArray *components;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *local;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@end @implementation NWSGoogleMapsResult @end


@implementation NWSGoogleMapsViewController {
    MKMapView *_mapView;
    UILabel *_label;
    NWSEndpoint *_endpoint;
    CLLocationManager *_manager;
}

- (NWSEndpoint *)setupReverseGeoEndpoint
{
    NWSBlockTransform *cityTransform = [[NWSBlockTransform alloc] initWithBlock:^id(NSArray *components, NWSMappingContext *context) {
        for (NSDictionary *component in components) {
            if ([component[@"types"][0] isEqualToString:@"locality"]) {
                return component[@"long_name"];
            }
        }
        return nil;
    }];
    
    NWSBlockTransform *countryTransform = [[NWSBlockTransform alloc] initWithBlock:^id(NSArray *components, NWSMappingContext *context) {
        for (NSDictionary *component in components) {
            if ([component[@"types"][0] isEqualToString:@"country"]) {
                return component[@"long_name"];
            }
        }
        return nil;
    }];
    
    NWSMapping *resultMapping = [[NWSMapping alloc] init];
    [resultMapping setObjectClass:NWSGoogleMapsResult.class];
    [resultMapping addAttributeWithElementPath:@"formatted_address" objectPath:@"formatted"];
    [resultMapping addAttributeWithElementPath:@"address_components" objectPath:@"city" transform:cityTransform];
    [resultMapping addAttributeWithElementPath:@"address_components" objectPath:@"country" transform:countryTransform];
    
    NWSBasicStore *store = [[NWSBasicStore alloc] init];

    NWSHTTPEndpoint *result = [[NWSHTTPEndpoint alloc] init];
    result.urlString = @"http://maps.googleapis.com/maps/api/geocode/json?latlng=$(latitude),$(longitude)&sensor=true";
    result.responseMapping = resultMapping;
    result.responsePath = [NWSPath pathFromString:@"results.0"];
    result.store = store;
    result.indicator = NWSNetworkActivityIndicator.shared;

    return result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // setup Spaghetti endpoint
    _endpoint = [self setupReverseGeoEndpoint];

    // mapview
    CGRect b = self.view.bounds;
    _mapView = [[MKMapView alloc] initWithFrame:b];
    [self.view addSubview:_mapView];
    
    // text label
    _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, b.size.width - 40, 40)];
    _label.font = [UIFont systemFontOfSize:13];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"Tap below to lookup you location..";
    [self.view addSubview:_label];
    
    // lookup button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, b.size.height - 100, b.size.width - 40, 40);
    [button setTitle:@"What's here?" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(press) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // start location updates
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    [manager startUpdatingLocation];
    _manager = manager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // set map to current location
    CLLocation *location = locations.lastObject;
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, 10000, 10000) animated:YES];
    [_manager stopUpdatingLocation];
    _manager.delegate = nil;
    _manager = nil;
}

- (void)press
{
    // lookup city and country
    CLLocationCoordinate2D coord = _mapView.centerCoordinate;
    [_endpoint startWithParameters:@{@"latitude":@(coord.latitude), @"longitude":@(coord.longitude)} block:^(NWSGoogleMapsResult *result) {
        _label.text = [NSString stringWithFormat:@"%@ in %@", result.city, result.country];
    }];
}

@end
