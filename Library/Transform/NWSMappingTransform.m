//
//  NWSMappingTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMappingTransform.h"
#import "NWSCommon.h"
#import "NWSMapping.h"


@implementation NWSMappingTransform


#pragma mark - Object life cycle

- (id)initWithMapping:(NWSMapping *)mapping
{
    self = [super init];
    if (self) {
        _mapping = mapping;
    }
    return self;
}


#pragma mark - NWSTransform

- (NWSObjectID *)transform:(NSObject *)value context:(NWSMappingContext *)context
{
    if (value) {
        return [_mapping mapElement:value context:context];
    } else {
        // object is nil, so we return nil object id
        return nil;
    }
}

- (NSObject *)reverse:(NWSObjectID *)identifier context:(NWSMappingContext *)context
{
    if (identifier) {
        return [_mapping mapIdentifier:identifier context:context];
    } else {
        // object id is nil, so we return nil object
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p mapping:%@>", NSStringFromClass(self.class), self, _mapping];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"transform with %@", [_mapping readable:prefix]] readable:prefix];
}

@end
