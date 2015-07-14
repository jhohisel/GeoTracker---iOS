//
//  MovementData.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/12/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovementData : NSObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double speed;
@property (nonatomic, strong) NSString *heading;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *timestamp;

- (id)initWithLatitude:(double)latitude longitude:(double)longitude speed:(double)speed heading:(NSString *)heading userid:(NSString *)userid timestamp:(NSString *)timestamp;

@end
