//
//  ChangePassViewController.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/26/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "ChangePassViewController.h"

@implementation ChangePassViewController
@synthesize password, confirmPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [path stringByAppendingPathComponent:@"UserData.plist"];
    NSLog(@"plistPath: %@", plistPath);
    NSError *copyFileError;
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"UserData" ofType:@"plist"];
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
    }
    savedEmail = [savedData objectForKey:@"Email"];
    savedQuestion = [savedData objectForKey:@"SecurityQuestion"];
    savedAnswer = [savedData objectForKey:@"SecurityAnswer"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)submit:(id)sender {
    
    if (!savedData) {
        NSLog(@"Error reading saved data!");
    }
    // Handle actual registering
    if ([password.text isEqualToString:[confirmPassword text]]) {
        
        // Check password length
        if (password.text.length >= 8) {
        
            NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     savedEmail, @"Email",
                                     password.text, @"Password",
                                     savedAnswer, @"SecurityAnswer",
                                     savedQuestion, @"SecurityQuestion",
                                     nil];
            NSLog(@"Saved question: %@", savedQuestion);
            NSLog(@"Saved answer: %@", savedAnswer);
            NSData *regPlist = [NSPropertyListSerialization dataWithPropertyList:regDict
                                                                          format:NSPropertyListXMLFormat_v1_0
                                                                         options:NSPropertyListMutableContainersAndLeaves
                                                                           error:nil];
            if (regPlist) {
                if([regPlist writeToFile:plistPath atomically:YES]) {
                    NSLog(@"Successfully saved the data to file: %@", plistPath);
                    // Then do views
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                    message:@"Password successfully changed."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    NSLog(@"Error writing data to path: %@", plistPath);
                }
            } else {
                NSLog(@"Error writing to plist file!");
            }
            
        } else {
            
            [password setText:@""];
            [confirmPassword setText:@""];
            [[self password] becomeFirstResponder];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Password is too short! Please select a password of at least 8 characters."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
    } else {
        [password setText:@""];
        [confirmPassword setText:@""];
        [[self password] becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Passwords don't match, try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Dismiss the keyboard when the user touches outside of the TextView
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
