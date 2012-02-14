//
//  NWSMappingTransform.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMappingTransform.h"
#import "NWSCommon.h"
#import "NWSMapping.h"


@implementation NWSMappingTransform

@synthesize mapping;


#pragma mark - Object life cycle

- (id)initWithMapping:(NWSMapping *)_mapping
{
    self = [super init];
    if (self) {
        mapping = _mapping;
    }
    return self;
}


#pragma mark - NWSTransform

- (NWSObjectID *)transform:(NSObject *)value context:(NWSMappingContext *)context
{
    if (value) {
        return [mapping mapElement:value context:context];
    } else {
        // object is nil, so we return nil object id
        return nil;
    }
}

- (NSObject *)reverse:(NWSObjectID *)identifier context:(NWSMappingContext *)context
{
    if (identifier) {
        return [mapping mapIdentifier:identifier context:context];
    } else {
        // object id is nil, so we return nil object
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p mapping:%@>", NSStringFromClass(self.class), self, mapping];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"transform with %@", [mapping readable:prefix]] readable:prefix];
}

@end
