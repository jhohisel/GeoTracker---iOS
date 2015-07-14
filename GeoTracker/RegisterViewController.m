//
//  RegisterView.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/21/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserAgreement.h"
#import "JFBCrypt.h"

#define WEBURL @"http://threeguyssecurity.com/geotracker/register.php"
#define ACCESS_CODE @"66E2094E"

@implementation RegisterViewController

@synthesize email, password, confirmPassword, answer, questionPicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    request = [[NSMutableURLRequest alloc] init];
    
    UserAgreement *u = [[UserAgreement alloc] init];
    [u fetchAgreement];
    
    [indicator setHidden:true];

    _questionList = @[@"--Security Question--", @"Name of your first pet", @"Mother's maiden name", @"City you were born in"];
    self.questionPicker.dataSource = self;
    self.questionPicker.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _questionList.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _questionList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedRow = row;
    selectedComponent = component;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    
    NSLog(@"Did receive data");
    
    [indicator stopAnimating];
    [indicator setHidden:true];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
    
    // Receive error
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *r = json;
        
        // Convert data to JSON object
        
        if ([[r objectForKey:@"result"] isEqualToString:@"fail"]) {
            
            [email becomeFirstResponder];
            [email setText:@""];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[r objectForKey:@"error"]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else if ([[r objectForKey:@"result"] isEqualToString:@"success"]) {
            
            NSLog(@"Successfully connected");
            [self dismissViewControllerAnimated:true completion:nil];
            
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Do stuff after registering to server
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // Selected "I agree" button
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"I agree"]){
        
        // Start indicator
        [indicator startAnimating];
        [indicator setHidden:false];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
        
        // Do connection
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (!conn) {
            [indicator stopAnimating];
            [indicator setHidden:true];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Something unexpected went wrong, maybe you're not connected to the Internet?"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

- (IBAction)submit:(id)sender {
    
    // Then register
    [self register];
    
}

- (void)register {
    
    if (selectedRow == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You did not select a security question." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    } else { // They did select a question, so move on
        
        // Handle actual registering
        
        if ([self isValidEmail] && [self isValidPassword] && [self isValidAnswer]) {
            
            NSString *salt = [JFBCrypt generateSaltWithNumberOfRounds:12];
            NSString *parameters = [NSString stringWithFormat:@"access=%@&email=%@&pass=%@&salt=%@&q=%@&a=%@",
                                    ACCESS_CODE,
                                    email.text,
                                    [JFBCrypt hashPassword:[password text] withSalt:salt],
                                    salt,
                                    [_questionList objectAtIndex:[questionPicker selectedRowInComponent:0]],
                                    [answer text]];
            NSData *parameterData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:true];
            NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[parameterData length]];
            
            // Create POST request data
            [request setURL:[NSURL URLWithString:WEBURL]];
            [request setHTTPMethod:@"POST"];
            [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:parameterData];
            
//            // Do connection
//            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//            if (conn) {
//                NSLog(@"Successfully connected");
//            } else {
//                NSLog(@"Error connecting to server");
//            }
            
            // Fetch agreement from server
            UserAgreement *u = [[UserAgreement alloc] init];
            
            // Do agreement
            UIAlertView *agreement = [[UIAlertView alloc] initWithTitle:@"User Agreement"
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:@"Decline"
                                                      otherButtonTitles:@"I agree", nil];
            
            // Web view to format HTML
            UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(12.5, 45.0, 265.0, 375.0)];
            
            // Set the web view content to the user agreement HTML
            [web loadHTMLString:[u getAgreement] baseURL:nil];
            
            // Add to alert
            [agreement setValue:web forKey:@"accessoryView"];
            
            // Show
            [agreement show];

        }
    }
    
}

- (BOOL)isValidEmail {
    
    if (![[email text] containsString:@"@"]) {
        
        [email setText:@""];
        [[self email] becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        return false;
        
    }
    return true;
}

- (BOOL)isValidPassword {
    
    if (![[password text] isEqualToString:[confirmPassword text]]) {
        
        [password setText:@""];
        [confirmPassword setText:@""];
        [[self password] becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords don't match, try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        return false;
    }
    
    if (!([[password text] length] >= 5)) {
        
        [password setText:@""];
        [confirmPassword setText:@""];
        [[self password] becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password is too short! Please select a password of at least eight characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return false;
    }
    
    return true;
}

- (BOOL)isValidAnswer {
    
    if (!([[answer text] length] >= 5)) {
        
        [answer setText:@""];
        [[self answer] becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Answer is too short! Answer must be at least three characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return false;
    }
    
    return true;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Dismiss the keyboard when the user touches outside of the TextView
    [self.view endEditing:true];
    [super touchesBegan:touches withEvent:event];
}

@end
