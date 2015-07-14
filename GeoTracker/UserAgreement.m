//
//  UserAgreement.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/13/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "UserAgreement.h"

#define WEBURL @"http://threeguyssecurity.com/geotracker/agreement.html"

@implementation UserAgreement

NSString static *agreement;

- (id)init {
    
    self = [super init];
    return self;
}

- (void)fetchAgreement {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:WEBURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    agreement = [[NSString alloc] init];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        NSLog(@"Successfully connected, sending url: %@", WEBURL);
    } else {
        NSLog(@"Error connecting to server");
    }
}

- (NSString *)getAgreement {
    
    return agreement;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    // Convert NSData object to NSString
    agreement = [agreement stringByAppendingString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    // Strip the invalid JSON from the response (why didn't you just use HTML, why bother with JSON?!)
//    agreement = [agreement stringByReplacingOccurrencesOfString:@"{\"agreement\": \"" withString:@""];
//    agreement = [agreement stringByReplacingOccurrencesOfString:@"\"}" withString:@""];
    NSLog(@"Found user agreement string: %@", agreement);
    
}

@end
