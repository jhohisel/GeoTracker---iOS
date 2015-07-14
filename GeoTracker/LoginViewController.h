//
//  LoginView.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/4/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    IBOutlet UITextField *email;
    IBOutlet UITextField *password;
    NSString *savedEmail;
    NSString *savedPassword;
    
    NSString *plistPath;
    NSDictionary *savedData;
}

@property(nonatomic, retain) UITextField *email;
@property(nonatomic, retain) UITextField *password;
@property(nonatomic, retain) NSString *savedEmail;
@property(nonatomic, retain) NSString *savedPassword;

- (IBAction)login:(id)sender;
- (IBAction)forgot:(id)sender;

@end
