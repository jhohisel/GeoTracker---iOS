//
//  UserAgreement.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/13/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAgreement : NSObject

- (id)init;
- (void)fetchAgreement;
- (NSString *)getAgreement;

@end
