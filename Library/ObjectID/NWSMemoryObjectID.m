//
//  NWSMemoryObjectID.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMemoryObjectID.h"
#import "NWSCommon.h"


@implementation NWSMemoryObjectID


#pragma mark - Object life cycle

- (id)initWithObject:(NSObject *)object
{
    self = [super init];
    if (self) {
        _object = object;
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
    return 5982874419 + _object.hash;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p object:%@>", NSStringFromClass(self.class), self, _object];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"id %@ in memory", NSStringFromClass(_object.class)] readable:prefix];
}

@end
