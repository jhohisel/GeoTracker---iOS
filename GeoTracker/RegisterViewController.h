//
//  RegisterView.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/21/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UITextField *email;
    IBOutlet UITextField *password;
    IBOutlet UITextField *confirmPassword;
    IBOutlet UITextField *answer;
    IBOutlet UIActivityIndicatorView *indicator;
    
    NSDictionary *savedData;
    NSString *plistPath;
    
    NSArray *_questionList;
    NSInteger selectedRow;
    NSInteger selectedComponent;
    
    NSMutableURLRequest *request;
}

@property (nonatomic, retain) UITextField *email;
@property (nonatomic, retain) UITextField *password;
@property (nonatomic, retain) UITextField *confirmPassword;
@property (nonatomic, retain) UITextField *answer;
@property (weak, nonatomic) IBOutlet UIPickerView *questionPicker;

- (IBAction)submit:(id)sender;
- (IBAction)cancel:(id)sender;

@end
