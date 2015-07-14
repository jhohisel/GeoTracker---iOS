//
//  ResetView.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 4/21/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetViewController : UIViewController
{
    IBOutlet UITextField *email;
}

@property(nonatomic, retain) UITextField *email;

- (IBAction)send:(id)sender;
- (IBAction)back:(id)sender;

@end
