//
//  ChangePassViewController.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/26/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePassViewController : UIViewController
{
    IBOutlet UITextField *password;
    IBOutlet UITextField *confirmPassword;
    
    NSDictionary *savedData;
    NSString *plistPath;
    NSString *savedEmail;
    NSString *savedAnswer;
    NSString *savedQuestion;
    
}
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UITextField *confirmPassword;

- (IBAction)back:(id)sender;
- (IBAction)submit:(id)sender;

@end
