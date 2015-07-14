//
//  SettingsViewController.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 6/3/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController {
    
    NSString *plistPath;
    NSDictionary *savedData;
}

@property (nonatomic) IBOutlet UISwitch *trackingSwitch;
@property (nonatomic) IBOutlet UISlider *trackingIntervalSlider;
@property (nonatomic) IBOutlet UIButton *dumpDataButton;

- (IBAction)dumpData:(id)sender;

@end
