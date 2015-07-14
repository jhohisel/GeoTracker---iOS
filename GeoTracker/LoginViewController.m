//
//  LoginView.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/4/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "LoginViewController.h"
#import "AccountViewController.h"
#import "RegisterViewController.h"
#import "ResetViewController.h"
#import "JFBCrypt.h"

#define WEBURL @"http://threeguyssecurity.com/geotracker/login.php"

@implementation LoginViewController
@synthesize email, password;
@synthesize savedEmail, savedPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Change back button to "Logout"
    [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:nil
                                                                                action:nil]];
    
    // Set up the plist file to save the user id
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received response: %@", result);
    
    // Receive result
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *r = json;
        
        if ([[r objectForKey:@"result"] isEqualToString:@"success"]) {
            
            NSString *pwHash = [JFBCrypt hashPassword:[password text] withSalt:[r objectForKey:@"salt"]];
            
            if ([pwHash isEqualToString:[r objectForKey:@"password"]]) {
            
                // Clear out fields
                [email setText:@""];
                [password setText:@""];
                [[self email] becomeFirstResponder];
            
                // Save UID, then go to MyAccount
                NSString *userID = [r objectForKey:@"userid"];
                NSDictionary *storedData = [[NSDictionary alloc] initWithObjectsAndKeys:userID, @"UserID",
                                            [savedData objectForKey:@"Interval"], @"Interval",
                                            [savedData objectForKey:@"Tracking"], @"Tracking", nil];

                NSData *plist = [NSPropertyListSerialization dataWithPropertyList:storedData
                                                                       format:NSPropertyListXMLFormat_v1_0
                                                                      options:NSPropertyListMutableContainersAndLeaves
                                                                        error:nil];
                
                if ([plist writeToFile:plistPath atomically:YES]) {
                    NSLog(@"User ID saved successfully!");
                } else {
                    NSLog(@"Error saving user id");
                }
            
                // Take the user to the My Account page
                AccountViewController *myAccount = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]    instantiateViewControllerWithIdentifier:@"AccountViewController"];
                [[self navigationController] pushViewController:myAccount animated:YES];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Incorrect password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[r objectForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction)login:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
    NSString *parameters = [NSString stringWithFormat:@"email=%@", email.text];
    NSData *parameterData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:true];
    NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[parameterData length]];
    
    // Create POST request data
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:WEBURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:parameterData];
    
    // Do connection
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        NSLog(@"Successfully connected");
    } else {
        NSLog(@"Error connecting to server");
    }
}

- (IBAction)forgot:(id)sender {

    ResetViewController *resetView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ResetViewController"];
    [self presentViewController:resetView animated:true completion:nil];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Dismiss the keyboard when the user touches outside of the TextView
    [[self view] endEditing:true];
    [super touchesBegan:touches withEvent:event];
}

@end
