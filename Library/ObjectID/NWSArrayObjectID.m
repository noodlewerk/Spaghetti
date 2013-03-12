//
//  NWSArrayObjectID.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSArrayObjectID.h"
#import "NWSCommon.h"


@implementation NWSArrayObjectID


#pragma mark - Object life cycle

- (id)initWithIdentifiers:(NSArray *)identifiers
{
    self = [super init];
    if (self) {
        _identifiers = identifiers;
    }
    return self;
}

- (BOOL)isEqual:(NWSArrayObjectID *)identifier
{
    return self == identifier || (self.class == identifier.class && [self.identifiers isEqualToArray:identifier.identifiers]);
}

- (NSUInteger)hash
{
    NSUInteger result = 6773872643;
    for (NWSObjectID *i in _identifiers) {
        result = 31 * result + i.hash;
    }
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p identifiers:%@>", NSStringFromClass(self.class), self, _identifiers];
}

- (NSString *)readable:(NSString *)prefix
{
    return [_identifiers readable:prefix];
}

@end
