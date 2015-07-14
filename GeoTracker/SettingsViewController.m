//
//  SettingsViewController.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 6/3/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "SettingsViewController.h"
#import "LocationServices.h"

#define WEBURL @"http://threeguyssecurity.com/geotracker/addloc.php"
#define ACCESS_CODE @"66E2094E"

@implementation SettingsViewController
@synthesize trackingSwitch, trackingIntervalSlider, dumpDataButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationItem] setTitle:@"Settings"];
    
    [trackingSwitch addTarget:self
                       action:@selector(switchDidChangeState:)
             forControlEvents:UIControlEventValueChanged];
    
    [trackingIntervalSlider addTarget:self
                               action:@selector(sliderDidUpdateInterval:)
                     forControlEvents:UIControlEventValueChanged];
    [trackingIntervalSlider setMinimumValue:0.0];
    [trackingIntervalSlider setMaximumValue:8.0];
    
    // Set up the plist file to get/store the saved interval
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    plistPath = [documentsPath stringByAppendingPathComponent:@"Data.plist"];
    
    // Create the file if it doesn't already exist
    NSError *copyFileError;
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"plist file doesn't exist, copying a new one");
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:plistPath error:&copyFileError];
        if (copyFileError) {
            NSLog(@"%@", copyFileError);
        }
    }
    
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSPropertyListFormat format;
    savedData = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistData
                                                                                        options:NSPropertyListMutableContainersAndLeaves
                                                                                         format:&format
                                                                                          error:nil];
    if (!savedData) {
        NSLog(@"Error reading plist file!");
    } else {
        NSLog(@"Slider set to %f", [[savedData objectForKey:@"Interval"] floatValue]);
        [trackingIntervalSlider setValue:[[savedData objectForKey:@"Interval"] floatValue]];
        NSLog(@"Tracking set to %@", [savedData objectForKey:@"Tracking"]);
        [[savedData objectForKey:@"Tracking"] isEqualToString:@"true"] ? [trackingSwitch setOn:true] : [trackingSwitch setOn:false];
    }
    
}

- (IBAction)dumpData:(id)sender {
    
    MovementDBHandler *myDB = [[MovementDBHandler alloc] init];
    NSArray *allPoints = [myDB getAllMovement];
    for (MovementData *d in allPoints) {
        NSLog(@"Uploading - Latitude: %f, Longitude: %f", [d latitude], [d longitude]);
        NSString *parameters = [NSString stringWithFormat:@"access=%@&lat=%f&lon=%f&speed=%f&heading=%@&userid=%@&timestamp=%@",
                                ACCESS_CODE,
                                [d latitude],
                                [d longitude],
                                [d speed],
                                [d heading],
                                [d userid],
                                [d timestamp]];
        
        NSData *parameterData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:true];
        NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[parameterData length]];
        
        // Create POST request data
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:WEBURL]];
        [request setHTTPMethod:@"POST"];
        [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:parameterData];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
        
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (conn) {
            NSLog(@"Successfully connected, sending url: %@", [WEBURL stringByAppendingString:parameters]);
        } else {
            NSLog(@"Error connecting to server");
        }
    }
    [myDB deleteAllMovement];
    
}

- (void)switchDidChangeState:(id)sender {

    LocationServices *ls = [LocationServices getInstance];
    
    NSString *isTracking = ([sender isOn] == true ? @"true" : @"false");
    
    NSLog(@"Tracking state set to: %@", isTracking);
    
    // Save tracking state
    NSDictionary *storedData = [[NSDictionary alloc] initWithObjectsAndKeys:[savedData objectForKey:@"UserID"], @"UserID",
                                                                            [savedData objectForKey:@"Interval"], @"Interval",
                                                                            isTracking, @"Tracking", nil];
    
    NSData *plist = [NSPropertyListSerialization dataWithPropertyList:storedData
                                                               format:NSPropertyListXMLFormat_v1_0
                                                                options:NSPropertyListMutableContainersAndLeaves
                                                                error:nil];
    if ([plist writeToFile:plistPath atomically:YES]) {
        
        NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSPropertyListFormat format;
        savedData = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistData
                                                                              options:NSPropertyListMutableContainersAndLeaves
                                                                               format:&format
                                                                                error:nil];
        
        NSLog(@"Tracking state saved successfully!");
        NSLog(@"Tracking state is: %@", [savedData objectForKey:@"Tracking"]);
    } else {
        NSLog(@"Error saving tracking state");
    }
    
    if ([sender isOn]) {
        
        NSNumber *interval;
        
        if (!savedData) {
            NSLog(@"Error reading plist file!");
        } else {
            interval = [savedData objectForKey:@"Interval"];
            NSLog(@"Retrieved saved interval: %d", [interval intValue]);
        }
        
        [ls startGatheringWithInterval:[self convertNotchToInterval:[interval intValue]]];
    
    } else {
        
        [ls stopGathering];
    }
}

- (int)convertNotchToInterval:(int)notch {
    
    int interval;
    
    int defaultInterval = 60;
    int lessOffset = 10;
    int greaterOffset = 60;
    
    if (notch < 4) {
        interval = defaultInterval - ((4 - notch) * lessOffset);
    } else if (notch == 4) {
        interval = defaultInterval;
    } else { // progress > 4
        interval = defaultInterval + ((notch - 4) * greaterOffset);
    }
    
    if (interval < 60) {
        //underText.setText("Interval: " + interval + " seconds");
    } else if (interval == 60) {
        //underText.setText("Interval: 1 minute");
    } else if (interval == 3600) {
        //underText.setText("Interval: 1 hour");
    } else if (interval > 3600) {
        //underText.setText("Interval: " + (interval / 3600) + " hours");
    } else {
        if ((interval / 60) % 10 == 0) {
            //underText.setText("Interval: " + (interval / 60) + " minutes");
        } else {
            //underText.setText("Interval: " + (interval / 60) + " minutes");
        }
    }
    
    return interval;
}

- (void)sliderDidUpdateInterval:(UISlider *)sender {
    
    int notch = (int)lround(sender.value);
    int interval = [self convertNotchToInterval:notch];
    sender.value = notch;
    
    // Get new interval
    NSLog(@"New interval: %d", interval);
    
    NSString *intervalString = [NSString stringWithFormat:@"%d", notch];
    
    NSLog(@"Interval saved as: %@", intervalString);
    
    // Save new interval
    NSDictionary *storedData = [[NSDictionary alloc] initWithObjectsAndKeys: [savedData objectForKey:@"UserID"], @"UserID",
                                                                             intervalString, @"Interval",
                                                                             [savedData objectForKey:@"Tracking"], @"Tracking", nil];
    
    NSData *plist = [NSPropertyListSerialization dataWithPropertyList:storedData
                                                               format:NSPropertyListXMLFormat_v1_0
                                                              options:NSPropertyListMutableContainersAndLeaves
                                                                error:nil];
    if ([plist writeToFile:plistPath atomically:YES]) {
        NSLog(@"Interval saved successfully!");
        
        // Reload data from plist
        NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSPropertyListFormat format;
        savedData = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistData
                                                                              options:NSPropertyListMutableContainersAndLeaves
                                                                               format:&format
                                                                                error:nil];
    } else {
        NSLog(@"Error saving interval");
    }
    
    // Start tracking with new interval if we are currently tracking
    if ([[savedData objectForKey:@"Tracking"] isEqualToString:@"true"]) {
        LocationServices *ls = [LocationServices getInstance];
        [ls stopGathering];
        [ls startGatheringWithInterval:interval];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
