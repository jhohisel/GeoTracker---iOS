//
//  MovementData.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/12/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "MovementData.h"

@implementation MovementData
@synthesize latitude, longitude, speed, heading, userid, timestamp;

- (id)initWithLatitude:(double)theLatitude longitude:(double)theLongitude speed:(double)theSpeed heading:(NSString *)theHeading userid:(NSString *)theUserid timestamp:(NSString *)theTimestamp {
    
    self = [super init];
    if (self) {

        [self setLatitude:theLatitude];
        [self setLongitude:theLongitude];
        [self setSpeed:theSpeed];
        [self setHeading:theHeading];
        [self setUserid:theUserid];
        [self setTimestamp:theTimestamp];
        
    }
    return self;
}

@end
