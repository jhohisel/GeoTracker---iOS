//
//  AccountView.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/4/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "AccountViewController.h"
#import "TrajectoryViewController.h"
#import "LocationServices.h"
#import "SettingsViewController.h"

#define WEBURL @"http://threeguyssecurity.com/geotracker/addloc.php"
#define ACCESS_CODE @"66E2094E"

@implementation AccountViewController
@synthesize uid;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationItem] setTitle:@"My Account"];
    [[self navigationItem] setHidesBackButton:NO];
    [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStyleDone target:nil action:nil]];
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsView)]];
    
    // Fetch the current user id
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"Data.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"No user id has been saved!!!");
    }
    
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSPropertyListFormat format;
    NSDictionary *savedData = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistData
                                                                                        options:NSPropertyListMutableContainersAndLeaves
                                                                                         format:&format
                                                                                          error:nil];
    
    NSString *isTracking;
    
    if (!savedData) {
        NSLog(@"Error reading plist file!");
    } else {
        uid = [savedData objectForKey:@"UserID"];
        isTracking = [savedData objectForKey:@"Tracking"];
        NSLog(@"isTracking: %@", [savedData objectForKey:@"Tracking"]);
        NSLog(@"Retrieved user id: %@", uid);
    }
    
    // Start gathering location on a separate thread
    if ([isTracking isEqualToString:@"true"]) {
        [self performSelectorInBackground:@selector(startTrackingForUser:) withObject:uid];
    }
}

- (void)startTrackingForUser:(NSString *)userid {
    [LocationServices initWithUser:userid];
    LocationServices *ls = [LocationServices getInstance];
    [ls startGatheringWithInterval:60];
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

- (void)showSettingsView {
    
    SettingsViewController *settingsView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [[self navigationController] pushViewController:settingsView animated:true];
    
}

- (IBAction)showMyTrajectory:(id)sender {
    
        TrajectoryViewController *trajectoryView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TrajectoryViewController"];
        [trajectoryView setStartDate:[startPicker date]];
        [trajectoryView setEndDate:[endPicker date]];
        [[self navigationController] pushViewController:trajectoryView animated:YES];
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"End date must be greater than or equal to start date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
    
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Dismiss the keyboard when the user touches outside of the TextView
    [[self view] endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
