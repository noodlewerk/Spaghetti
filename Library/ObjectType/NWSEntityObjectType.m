//
//  NWSEntityObjectType.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSEntityObjectType.h"
#import "NWSCommon.h"
#import "NWSSingleKeyPath.h"
#import "NWSSelfPath.h"


@implementation NWSEntityObjectType


#pragma mark - Object life cycle

- (id)initWithEntity:(NSEntityDescription *)entity
{
    self = [super init];
    if (self) {
        _entity = entity;
    }
    return self;
}

- (BOOL)isEqual:(NWSEntityObjectType *)type
{
    return self == type || (self.class == type.class && [self.entity isEqual:type.entity]);
}

- (NSUInteger)hash
{
    return 8132572160 + _entity.hash;
}


#pragma mark - Object Type

- (BOOL)matches:(id)object
{
    if ([object isKindOfClass:NSManagedObject.class]) {
        NSManagedObject *o = (NSManagedObject *)object;
        return [_entity isEqual:o.entity];
    } else {
        NWLogWarn(@"object not supported: %@", object); // COV_NF_LINE
        return NO; // COV_NF_LINE
    }
}

+ (BOOL)supports:(NSObject *)object
{
    return [object isKindOfClass:NSManagedObject.class];
}

- (BOOL)hasAttribute:(NWSPath *)attribute
{
    if ([attribute isKindOfClass:NWSSingleKeyPath.class]) {
        NWSSingleKeyPath *path = (NWSSingleKeyPath *)attribute;
        NSAttributeDescription *description = (_entity.attributesByName)[path.key];
        return description != nil;
    } else if ([attribute isKindOfClass:NWSSelfPath.class]) {
        return YES;
    } else {
        NWLogWarn(@"attribute not yet supported: %@", attribute); // COV_NF_LINE
        return NO; // COV_NF_LINE
    }
}

- (BOOL)hasRelation:(NWSPath *)relation toMany:(BOOL)toMany
{
    if ([relation isKindOfClass:NWSSingleKeyPath.class]) {
        NWSSingleKeyPath *path = (NWSSingleKeyPath *)relation;
        NSRelationshipDescription *description = (_entity.relationshipsByName)[path.key];
        if (!description) {
            return NO;
        }
        if (description.isToMany != toMany) {
            return NO;
        }
        return YES;
    } else {
        NWLogWarn(@"relation not yet supported: %@", relation); // COV_NF_LINE
        return NO; // COV_NF_LINE
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p entity:%@>", NSStringFromClass(self.class), self, _entity.name];
}

- (NSString *)readable:(NSString *)prefix
{
    return [_entity.name readable:prefix];
}

@end
