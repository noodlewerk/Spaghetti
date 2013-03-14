//
//  NWSIDToObjectTransform.m
//  Spaghetti
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
#import "NWSClassObjectType.h"
#import "NWSEntityObjectType.h"


@implementation NWSIDToObjectTransform

- (id)initWithCreateClass:(Class)clas
{
    return [self initWithType:[[NWSClassObjectType alloc] initWithClass:clas] path:nil];
}

- (id)initWithCreateEntity:(NSEntityDescription *)entity
{
    return [self initWithType:[[NWSEntityObjectType alloc] initWithEntity:entity] path:nil];
}

- (id)initWithType:(NWSObjectType *)type path:(NWSPath *)path
{
    self = [super init];
    if (self) {
        _type = type;
        _path = path;
        _create = YES;
    }
    return self;
}


#pragma mark - NWSTransform

- (NWSObjectID *)transform:(id)value context:(NWSMappingContext *)context
{
    if (value) {
        NWSStore *store = context.store;
        NSArray *pathsAndValues = _path ? @[_path, value] : nil;
        NWSObjectID *identifier = [store identifierWithType:_type primaryPathsAndValues:pathsAndValues create:_create];
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
        id value = [store attributeForIdentifier:identifier path:_path];
        return value;
    } else {
        // object is nil, so we return nil object id
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p type:%@ path:%@>", NSStringFromClass(self.class), self, _type, _path];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"transform %@ to %@", [_path readable:prefix], [_type readable:prefix]] readable:prefix];
}

@end
