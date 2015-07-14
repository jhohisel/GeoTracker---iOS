//
//  MovementDBHandler.h
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/12/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MovementData.h"

@interface MovementDBHandler : NSObject

- (id)init;
- (BOOL)addMovement:(MovementData *)location;
- (NSArray *)getAllMovement;
- (void)deleteAllMovement;

@end
