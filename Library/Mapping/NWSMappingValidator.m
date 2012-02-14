//
//  NWSMappingValidator.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMappingValidator.h"
#import "NWSCommon.h"
#import "NWSMapping.h"
#import "NWSPath.h"
#import "NWSObjectType.h"
#import "NWSArrayTransform.h"


@implementation NWSMappingValidator

@synthesize mapping;

- (void)validateAttributes
{
    if (mapping.objectType) {
        for (NWSMappingEntry *entry in mapping.attributes) {
            if (![mapping.objectType hasAttribute:entry.objectPath]) {
                NWLogWarn(@"Mapping %@ does not have to-attribute: %@", mapping.readable, entry.objectPath.readable); // COV_NF_LINE
            }
        }
    } else {
        NWLogWarn(@"Mapping %@ attributes cannot be validated without objectType", mapping.readable); // COV_NF_LINE
    }
}

- (void)validateRelations
{
    if (mapping.objectType) {
        for (NWSMappingEntry *entry in mapping.relations) {
            BOOL isToMany = [entry.transform isKindOfClass:NWSArrayTransform.class];
            if (![mapping.objectType hasRelation:entry.objectPath toMany:isToMany]) {
                NWLogWarn(@"Mapping %@ does not have to-relation: %@", mapping, entry.objectPath); // COV_NF_LINE
            }
        }
    } else {
        NWLogWarn(@"Mapping %@ relations cannot be validated without objectType", mapping.readable); // COV_NF_LINE
    }
}

- (void)validatePrimaryPath
{
    for (NWSMappingEntry *primary in mapping.primaries) {
        if (!primary.objectPath) {
            NWLogWarn(@"Mapping %@ does not have primary path set", mapping); // COV_NF_LINE
        }
        if (![mapping.objectType hasAttribute:primary.objectPath]) {
            NWLogWarn(@"Mapping %@ does not have primary attribute: %@", mapping.readable, primary.objectPath.readable); // COV_NF_LINE
        }
        if (!primary.elementPath) {
            NWLogWarn(@"Mapping %@ does not map primary element", mapping.readable); // COV_NF_LINE
        }
    }
}

- (void)validateMisc
{
    if (!mapping.attributes.count && !mapping.relations.count) {
        NWLogWarn(@"Mapping %@ has no attributes and no relations", mapping.readable); // COV_NF_LINE
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
    return [NSString stringWithFormat:@"<%@:%p mapping:%@>", NSStringFromClass(self.class), self, mapping.readable];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"validator for %@", [mapping readable:prefix]] readable:prefix];
}
          
@end
