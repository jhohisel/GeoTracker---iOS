//
//  TrajectoryViewController.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/21/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "TrajectoryViewController.h"
#import "MapPoint.h"
#import "MovementDBHandler.h"
#import "MovementData.h"

#define WEBURL @"http://threeguyssecurity.com/geotracker/view.php"
#define MAP_BUFFER 1.2

@implementation TrajectoryViewController
@synthesize startDate, endDate, retreivedData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationItem] setTitle:@"My Trajectory"];
    
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
    NSString *userID = @"";
    
    if (!savedData) {
        NSLog(@"Error reading plist file!");
    } else {
        userID = [savedData objectForKey:@"UserID"];
        NSLog(@"Retrieved user id: %@", userID);
    }
    
    // Fetch all data points for the current user id between the time intervals and display them on the map
    
    NSString *parameters = [NSString stringWithFormat:@"uid=%@&start=%@&end=%@",
                            userID,
                            [NSString stringWithFormat:@"%f", ([[[NSCalendar currentCalendar] startOfDayForDate:startDate] timeIntervalSince1970])],
                            [NSString stringWithFormat:@"%f", ([[[NSCalendar currentCalendar] startOfDayForDate:[endDate dateByAddingTimeInterval:60*60*24]] timeIntervalSince1970])]];
    
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
    retreivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [retreivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];

    id json = [NSJSONSerialization JSONObjectWithData:retreivedData options:0 error:nil];
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *r = json;
        
        if ([[r objectForKey:@"result"] isEqualToString:@"success"]) {
            
            NSArray *dataPoints = [r objectForKey:@"points"];
            
            double minLatitude = [[[dataPoints objectAtIndex:0] objectForKey:@"lat"] doubleValue];
            double maxLatitude = minLatitude;
            double minLongitude = [[[dataPoints objectAtIndex:0] objectForKey:@"lon"] doubleValue];
            double maxLongitude = minLongitude;
            
            for (NSDictionary *point in dataPoints) {
                
                NSLog(@"Latitude: %@, Longitude: %@", [point objectForKey:@"lat"], [point objectForKey:@"lon"]);
                
                CLLocationDegrees lat = [[point objectForKey:@"lat"] doubleValue], lon = [[point objectForKey:@"lon"] doubleValue];
                
                // Store min/max for centering the map
                if (minLatitude > lat)
                    minLatitude = lat;
                if (lat > maxLatitude)
                    maxLatitude = lat;
                if (minLongitude > lon)
                    minLongitude = lon;
                if (lon > maxLongitude)
                    maxLongitude = lon;
                
                [locMap addAnnotation:[[MapPoint alloc] initWithLocation:CLLocationCoordinate2DMake(lat, lon) andTitle:@"Point"]];
                
            }
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLatitude + maxLatitude) / 2, (minLongitude + maxLongitude) / 2);
            MKCoordinateSpan span;
            span.latitudeDelta = fabs((minLatitude - maxLatitude) * MAP_BUFFER);
            span.longitudeDelta = fabs((minLongitude - maxLongitude) * MAP_BUFFER);
            [locMap setRegion:MKCoordinateRegionMake(center, span) animated:true];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[r objectForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [[self navigationController] popViewControllerAnimated:true];
        }
        
    } else {
        NSLog(@"Returned object is invalid");
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
