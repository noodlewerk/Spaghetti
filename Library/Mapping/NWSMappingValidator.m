//
//  NWSMappingValidator.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMappingValidator.h"
#import "NWAbout.h"
#import "NWSMapping.h"
#import "NWSPath.h"
#import "NWSObjectType.h"
#import "NWSArrayTransform.h"
#include "NWLCore.h"


@implementation NWSMappingValidator

- (void)validateAttributes
{
    if (_mapping.objectType) {
        for (NWSMappingEntry *entry in _mapping.attributes) {
            if (![_mapping.objectType hasAttribute:entry.objectPath]) {
                NWLogWarn(@"Mapping %@ does not have to-attribute: %@", _mapping.about, entry.objectPath.about); // COV_NF_LINE
            }
        }
    } else {
        NWLogWarn(@"Mapping %@ attributes cannot be validated without objectType", _mapping.about); // COV_NF_LINE
    }
}

- (void)validateRelations
{
    if (_mapping.objectType) {
        for (NWSMappingEntry *entry in _mapping.relations) {
            BOOL isToMany = [entry.transform isKindOfClass:NWSArrayTransform.class];
            if (![_mapping.objectType hasRelation:entry.objectPath toMany:isToMany]) {
                NWLogWarn(@"Mapping %@ does not have to-relation: %@", _mapping, entry.objectPath); // COV_NF_LINE
            }
        }
    } else {
        NWLogWarn(@"Mapping %@ relations cannot be validated without objectType", _mapping.about); // COV_NF_LINE
    }
}

- (void)validatePrimaryPath
{
    for (NWSMappingEntry *primary in _mapping.primaries) {
        if (!primary.objectPath) {
            NWLogWarn(@"Mapping %@ does not have primary path set", _mapping); // COV_NF_LINE
        }
        if (![_mapping.objectType hasAttribute:primary.objectPath]) {
            NWLogWarn(@"Mapping %@ does not have primary attribute: %@", _mapping.about, primary.objectPath.about); // COV_NF_LINE
        }
        if (!primary.elementPath) {
            NWLogWarn(@"Mapping %@ does not map primary element", _mapping.about); // COV_NF_LINE
        }
    }
}

- (void)validateMisc
{
    if (!_mapping.attributes.count && !_mapping.relations.count) {
        NWLogWarn(@"Mapping %@ has no attributes and no relations", _mapping.about); // COV_NF_LINE
    }
}

- (void)validate
{
    [self validateAttributes];
    [self validateRelations];
    [self validatePrimaryPath];
    [self validateMisc];
}

+ (void)validate:(NWSMapping *)mapping
{
    NWSMappingValidator *validator = [[NWSMappingValidator alloc] init];
    validator.mapping = mapping;
    [validator validate];
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p mapping:%@>", NSStringFromClass(self.class), self, _mapping.about];
}

- (NSString *)about:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"validator for %@", [_mapping about:prefix]] about:prefix];
}
          
@end
