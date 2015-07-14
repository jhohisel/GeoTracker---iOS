//
//  TrajectoryViewController.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/21/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

@interface TrajectoryViewController : UIViewController
{
    IBOutlet MKMapView *locMap;
}
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSMutableData *retreivedData;

@end
