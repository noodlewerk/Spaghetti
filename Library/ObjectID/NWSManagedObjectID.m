//
//  NWSManagedObjectID.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSManagedObjectID.h"
#import "NWSCommon.h"


@implementation NWSManagedObjectID

@synthesize ID;


#pragma mark - Object life cycle

- (id)initWithID:(NSManagedObjectID *)_ID
{
    self = [super init];
    if (self) {
        NWLogWarnIfNot(_ID, @"Initializing an managed object ID with nil ID");
        ID = _ID;
    }
    return self;
}

- (BOOL)isEqual:(NWSManagedObjectID *)identifier
{
    return self == identifier || (self.class == identifier.class && [self.ID isEqual:identifier.ID]);
}

- (NSUInteger)hash
{
    return 1680565761 + ID.hash;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p ID:%@>", NSStringFromClass(self.class), self, ID];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"id of %@", ID.entity.name] readable:prefix];
}

@end
