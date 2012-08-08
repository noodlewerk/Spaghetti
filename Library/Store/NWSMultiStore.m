//
//  NWSMultiStore.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMultiStore.h"
#import "NWSCommon.h"
#import "NWSBasicStore.h"
#import "NWSEntityObjectType.h"
#import "NWSClassObjectType.h"
#import "NWSCoreDataStore.h"
#import "NWSManagedObjectID.h"
#import "NWSMemoryObjectID.h"
#import "NWSArrayObjectID.h"
#import "NWSObjectReference.h"


@implementation NWSMultiStore {
    NSMutableDictionary *storeForObjectTypeClass;
    NSMutableDictionary *storeForObjectIDClass;
    NSMutableArray *objectTypeClasses;
    NSMutableArray *objectIDClasses;
    NSMutableArray *stores;
}

@synthesize stores;


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        storeForObjectTypeClass = [[NSMutableDictionary alloc] init];
        storeForObjectIDClass = [[NSMutableDictionary alloc] init];
        stores = [[NSMutableArray alloc] init];
        objectTypeClasses = [[NSMutableArray alloc] init];
        objectIDClasses = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addStore:(NWSStore *)store objectTypeClass:(Class)objectTypeClass objectIDClass:(Class)objectIDClass
{
    [storeForObjectTypeClass setObject:store forKey:objectTypeClass];
    [storeForObjectIDClass setObject:store forKey:objectIDClass];
    [stores addObject:store];
    [objectTypeClasses addObject:objectTypeClass];
    [objectIDClasses addObject:objectIDClass];
}


#pragma mark - NWSStore

- (NWSObjectID *)identifierWithType:(NWSObjectType *)type primaryPathsAndValues:(NSArray *)pathsAndValues create:(BOOL)create
{
    NWSStore *store = [storeForObjectTypeClass objectForKey:type.class];
    NWLogWarnIfNot(store, @"No store for object type: %@", type);
    return [store identifierWithType:type primaryPathsAndValues:pathsAndValues create:create];
}

- (id)attributeForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path
{
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NWSArrayObjectID *i = (NWSArrayObjectID *)identifier;
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:i.identifiers.count];
        for (NWSObjectID *j in i.identifiers) {
            [result addObject:[self attributeForIdentifier:j path:path]];
        }
        return result;
    } else {
        NWSStore *store = [storeForObjectIDClass objectForKey:identifier.class];
        NWLogWarnIfNot(store, @"No store for object id: %@", identifier);
        return [store attributeForIdentifier:identifier path:path];
    }
}

- (NWSObjectID *)relationForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path
{
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NWSArrayObjectID *i = (NWSArrayObjectID *)identifier;
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:i.identifiers.count];
        for (NWSObjectID *j in i.identifiers) {
            [result addObject:[self relationForIdentifier:j path:path]];
        }
        return [[NWSArrayObjectID alloc] initWithIdentifiers:result];
    } else {
        NWSStore *store = [storeForObjectIDClass objectForKey:identifier.class];
        NWLogWarnIfNot(store, @"No store for object id: %@", identifier);
        return [store relationForIdentifier:identifier path:path];
    }
}

- (void)setAttributeForIdentifier:(NWSObjectID *)identifier value:(id)value path:(NWSPath *)path
{
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NWSArrayObjectID *i = (NWSArrayObjectID *)identifier;
        for (NWSObjectID *j in i.identifiers) {
            [self setAttributeForIdentifier:j value:value path:path];
        }
    } else {
        NWSStore *store = [storeForObjectIDClass objectForKey:identifier.class];
        NWLogWarnIfNot(store, @"No store for object id: %@", identifier);
        [store setAttributeForIdentifier:identifier value:value path:path];
    }
}

- (void)setRelationForIdentifier:(NWSObjectID *)identifier value:(NWSObjectID *)value path:(NWSPath *)path policy:(NWSPolicy *)policy baseStore:(NWSStore *)baseStore
{
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NWSArrayObjectID *i = (NWSArrayObjectID *)identifier;
        for (NWSObjectID *j in i.identifiers) {
            [self setRelationForIdentifier:j value:value path:path policy:policy baseStore:baseStore];
        }
    } else {
        NWSStore *store = [storeForObjectIDClass objectForKey:identifier.class];
        NWLogWarnIfNot(store, @"No store for object id: %@", identifier);
        [store setRelationForIdentifier:identifier value:value path:path policy:policy baseStore:baseStore ? baseStore : self];
    }
}

- (void)deleteObjectWithIdentifier:(NWSObjectID *)identifier
{
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NWSArrayObjectID *i = (NWSArrayObjectID *)identifier;
        for (NWSObjectID *j in i.identifiers) {
            [self deleteObjectWithIdentifier:j];
        }
    } else {
        NWSStore *store = [storeForObjectIDClass objectForKey:identifier.class];
        NWLogWarnIfNot(store, @"No store for object id: %@", identifier);
        [store deleteObjectWithIdentifier:identifier];
    }
}

- (NWSObjectReference *)referenceForIdentifier:(NWSObjectID *)identifier
{
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NWSArrayObjectID *i = (NWSArrayObjectID *)identifier;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:i.identifiers.count];
        for (NWSObjectID *j in i.identifiers) {
            [array addObject:[self referenceForIdentifier:j]];
        }
        return [[NWSObjectReference alloc] initWithObject:array];
    } else {
        NWSStore *store = [storeForObjectIDClass objectForKey:identifier.class];
        NWLogWarnIfNot(store, @"No store for object id: %@", identifier);
        return [store referenceForIdentifier:identifier];
    }
}

- (NWSObjectID *)identifierForObject:(id)object
{
    for (NWSObjectType *type in storeForObjectTypeClass) {
        if ([type matches:object]) {
            NWSStore *store = [storeForObjectTypeClass objectForKey:type];
            return [store identifierForObject:object];
        }
    }
    NWLogWarn(@"No object type matches object: %@", object);
    return nil;
}

- (NWSObjectType *)typeFromString:(NSString *)string
{
    for (NWSStore *store in stores) {
        NWSObjectType *type = [store typeFromString:string];
        if (type) {
            return type;
        }        
    }
    NWLogWarn(@"No object type matches string: %@", string);
    return nil;
}


#pragma mark - Transaction management

- (NWSStore *)beginTransaction
{
    NWSMultiStore *result = [[NWSMultiStore alloc] init];
    for (NSUInteger i = 0; i < stores.count; i++) {
        NWSStore *store = [stores objectAtIndex:i];
        Class typeClass = [objectTypeClasses objectAtIndex:i];
        Class idClass = [objectIDClasses objectAtIndex:i];
        [result addStore:[store beginTransaction] objectTypeClass:typeClass objectIDClass:idClass];
    }
    return result;
}

- (void)mergeTransaction:(NWSMultiStore *)store
{
    NWLogWarnIfNot([store isKindOfClass:NWSMultiStore.class], @"Multi store can only merge with multi store.");
    if (store.stores.count == stores.count) {
        for (NSUInteger i = 0; i < stores.count; i++) {
            [[stores objectAtIndex:i] mergeTransaction:[store.stores objectAtIndex:i]];
        }
    } else {
        NWLogWarn(@"Multi stores should have equal number of sub-stores: %i %i", (int)stores.count, (int)store.stores.count);
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p #stores:%u>", NSStringFromClass(self.class), self, stores.count];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"multi-store" readable:prefix];
}


#if DEBUG

- (NSArray *)allObjects
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NWSStore *store in stores) {
        [result addObjectsFromArray:[store allObjects]];
    }
    return result;
}

#endif


@end
