//
//  LocationServices.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/12/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "LocationServices.h"

@implementation LocationServices

static LocationServices *instance;
static CLLocationManager *manager;
static MovementDBHandler *dbHandler;
static NSString *userid;
static NSTimer *timer;

// Always use this constructor!!!
+ (void)initWithUser:(NSString *)theUserID {
    
    instance = [[super alloc] init];
    if (instance) {
        userid = theUserID;
        dbHandler = [[MovementDBHandler alloc] init];
    }
}

+ (id)getInstance {
    return instance;
}

- (void)startGatheringWithInterval:(int)intervalInSeconds {
    
    // Start Core Location
    manager = [[CLLocationManager alloc] init];
    [manager setDelegate:instance];
    [manager requestAlwaysAuthorization];
    [manager setDistanceFilter:kCLDistanceFilterNone];
    [manager startUpdatingLocation];
    
    timer = [NSTimer timerWithTimeInterval:(float)intervalInSeconds
                                    target:self
                                  selector:@selector(updateLocation)
                                  userInfo:nil
                                   repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    NSLog(@"Location services started");
}

- (void)stopGathering {
    
    [timer invalidate];
    [manager stopMonitoringSignificantLocationChanges];
    [manager stopUpdatingLocation];
    manager = NULL;
    NSLog(@"Location services stopped");
}

- (void)updateLocation {
    
    NSLog(@"Updating location...");
    
    // Re-start Core Location
    manager = [[CLLocationManager alloc] init];
    [manager setDelegate:self];
    [manager requestAlwaysAuthorization];
    [manager setDistanceFilter:kCLDistanceFilterNone];
    [manager startUpdatingLocation];
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"Not authorized for locations");
    } else {
        CLLocation *currentLocation = [manager location];
        NSLog(@"Current location is: latitude=%f, longitude=%f", [currentLocation coordinate].latitude, [currentLocation coordinate].longitude);
        MovementData *currentData = [[MovementData alloc] initWithLatitude:[currentLocation coordinate].latitude
                                                                 longitude:[currentLocation coordinate].longitude
                                                                     speed:[currentLocation speed]
                                                                   heading:[NSString stringWithFormat:@"%f", [currentLocation course]]
                                                                    userid:userid
                                                                 timestamp:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
        if ([dbHandler addMovement:currentData]) {
            NSLog(@"Movement added successfully!");
        } else {
            NSLog(@"Error adding location to database");
        }
    }
}

@end
