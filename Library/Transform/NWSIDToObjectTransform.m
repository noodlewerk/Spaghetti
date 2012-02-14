//
//  NWSIDToObjectTransform.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSIDToObjectTransform.h"
#import "NWSCommon.h"
#import "NWSStore.h"
#import "NWSObjectID.h"
#import "NWSMappingContext.h"
#import "NWSPath.h"
#import "NWSObjectType.h"


@implementation NWSIDToObjectTransform

@synthesize type, path, create;

- (id)initWithType:(NWSObjectType *)_type path:(NWSPath *)_path
{
    self = [super init];
    if (self) {
        type = _type;
        path = _path;
        create = YES;
    }
    return self;
}


#pragma mark - NWSTransform

- (NWSObjectID *)transform:(id)value context:(NWSMappingContext *)context
{
    if (value) {
        NWSStore *store = context.store;
        NSArray *pathsAndValues = [[NSArray alloc] initWithObjects:path, value, nil];
        NWSObjectID *identifier = [store identifierWithType:type primaryPathsAndValues:pathsAndValues create:create];
        return identifier;
    } else {
        // object id is nil, so we return nil object
        return nil;
    }
}

- (id)reverse:(NWSObjectID *)identifier context:(NWSMappingContext *)context
{
    if (identifier) {
        NWSStore *store = context.store;
        id value = [store attributeForIdentifier:identifier path:path];
        return value;
    } else {
        // object is nil, so we return nil object id
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p type:%@ path:%@>", NSStringFromClass(self.class), self, type, path];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"transform %@ to %@", [path readable:prefix], [type readable:prefix]] readable:prefix];
}

@end
