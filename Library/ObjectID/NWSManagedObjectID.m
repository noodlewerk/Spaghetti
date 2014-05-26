//
//  NWSManagedObjectID.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSManagedObjectID.h"
#import "NWAbout.h"
//#include "NWSLCore.h"


@implementation NWSManagedObjectID


#pragma mark - Object life cycle

- (id)initWithID:(NSManagedObjectID *)ID
{
    self = [super init];
    if (self) {
        NWSLogWarnIfNot(ID, @"Initializing an managed object ID with nil ID");
        _ID = ID;
    }
    return self;
}

- (BOOL)isEqual:(NWSManagedObjectID *)identifier
{
    return self == identifier || (self.class == identifier.class && [self.ID isEqual:identifier.ID]);
}

- (NSUInteger)hash
{
    return 1680565761 + _ID.hash;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p ID:%@>", NSStringFromClass(self.class), self, _ID];
}

- (NSString *)about:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"id of %@", _ID.entity.name] about:prefix];
}

@end
