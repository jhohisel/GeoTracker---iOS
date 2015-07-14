//
//  MapPoint.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/12/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint
@synthesize coordinate, locTitle, subtitle, tag;

- (id)initWithLocation:(CLLocationCoordinate2D)location andTitle:(NSString *)title {
    
    self = [super init];
    coordinate = location;
    locTitle = title;
    subtitle = [NSString stringWithFormat:@"%f, %f", location.latitude, location.longitude];
    return self;
    
}

@end
