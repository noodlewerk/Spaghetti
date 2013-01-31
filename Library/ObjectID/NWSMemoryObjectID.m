//
//  NWSMemoryObjectID.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMemoryObjectID.h"
#import "NWSCommon.h"


@implementation NWSMemoryObjectID

@synthesize object;


#pragma mark - Object life cycle

- (id)initWithObject:(NSObject *)_object
{
    self = [super init];
    if (self) {
        object = _object;
    }
    return self;
}

- (BOOL)isEqual:(NWSMemoryObjectID *)identifier
{
    // Uses object == object because we compare 'in-memory'
    return self == identifier || (self.class == identifier.class && self.object == identifier.object);
}

- (NSUInteger)hash
{
    return 5982874419 + object.hash;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p object:%@>", NSStringFromClass(self.class), self, object];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"id %@ in memory", NSStringFromClass(object.class)] readable:prefix];
}

@end
