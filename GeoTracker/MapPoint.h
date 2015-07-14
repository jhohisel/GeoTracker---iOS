//
//  MapPoint.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/12/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapPoint : NSObject <MKAnnotation> {
    
}
@property (nonatomic, copy) NSString *locTitle;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) NSUInteger tag;

- (id)initWithLocation:(CLLocationCoordinate2D)location andTitle:(NSString *)title;

@end
