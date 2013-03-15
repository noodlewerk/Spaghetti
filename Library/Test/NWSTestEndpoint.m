//
//  NWSTestEndpoint.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTestEndpoint.h"
#import "NWAbout.h"
#import "NWSTestCall.h"


@implementation NWSTestEndpoint {
    NSMutableDictionary *_headers;
}


#pragma mark - Object life cycle

- (id)newCall
{
    return [[NWSTestCall alloc] initWithEndpoint:self];
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"test-endpoint on %@" about:prefix];
}

@end

