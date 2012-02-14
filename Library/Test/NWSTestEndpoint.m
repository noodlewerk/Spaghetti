//
//  NWSTestEndpoint.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTestEndpoint.h"
#import "NWSCommon.h"
#import "NWSTestCall.h"


@implementation NWSTestEndpoint {
    NSMutableDictionary *headers;
}

@synthesize response;


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

- (NSString *)readable:(NSString *)prefix
{
    return [@"test-endpoint on %@" readable:prefix];
}

@end

