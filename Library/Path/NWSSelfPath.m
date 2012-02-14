//
//  NWSSelfPath.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSSelfPath.h"
#import "NWSCommon.h"


@implementation NWSSelfPath


#pragma mark - Object life cycle

+ (NWSSelfPath *)shared
{
    static NWSSelfPath *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSSelfPath alloc] init];
    });
    return result;
}

- (BOOL)isEqual:(NWSSelfPath *)path
{
    return self == path || self.class == path.class;
}

- (NSUInteger)hash
{
    return 1367426990;    
}


#pragma mark - Path

- (id)valueWithObject:(NSObject *)object
{
    return object;
}

- (void)setWithObject:(NSObject *)object value:(id)value
{
    // can't set object, can I?
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"path-to-self" readable:prefix];
}


@end
