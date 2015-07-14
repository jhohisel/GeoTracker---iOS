//
//  ResetView.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/21/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "ResetViewController.h"
#import "LoginViewController.h"

#define WEBURL @"http://450.atwebpages.com/reset.php"

@implementation ResetViewController
@synthesize email;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *r = json;
        
        if ([[r objectForKey:@"result"] isEqualToString:@"success"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instructions" message:[r objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [self dismissViewControllerAnimated:true completion:nil];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[r objectForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
        
    }
    
}

- (IBAction)send:(id)sender {
    
    NSString *parameters = [NSString stringWithFormat:@"?email=%@", [email text]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[WEBURL stringByAppendingString:parameters]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        NSLog(@"Successfully connected");
    } else {
        NSLog(@"Error connecting to server");
    }
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Dismiss the keyboard when the user touches outside of the TextView
    [[self view] endEditing:true];
    [super touchesBegan:touches withEvent:event];
}

@end
