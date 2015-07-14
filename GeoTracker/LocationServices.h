//
//  LocationServices.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/12/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MovementData.h"
#import "MovementDBHandler.h"

@interface LocationServices : NSObject <CLLocationManagerDelegate>

+ (id)getInstance;
+ (void)initWithUser:(NSString *)userid;

- (void)startGatheringWithInterval:(int)intervalInSeconds;
- (void)stopGathering;

@end
