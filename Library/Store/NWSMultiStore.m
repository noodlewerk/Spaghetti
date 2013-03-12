//
//  NWSMultiStore.m
//  Spaghetti
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
    NSMutableDictionary *_storeForObjectTypeClass;
    NSMutableDictionary *_storeForObjectIDClass;
    NSMutableArray *_objectTypeClasses;
    NSMutableArray *_objectIDClasses;
    NSMutableArray *_stores;
}


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        _storeForObjectTypeClass = [[NSMutableDictionary alloc] init];
        _storeForObjectIDClass = [[NSMutableDictionary alloc] init];
        _stores = [[NSMutableArray alloc] init];
        _objectTypeClasses = [[NSMutableArray alloc] init];
        _objectIDClasses = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addStore:(NWSStore *)store objectTypeClass:(Class)objectTypeClass objectIDClass:(Class)objectIDClass
{
    [_storeForObjectTypeClass setObject:store forKey:NSStringFromClass(objectTypeClass)];
    [_storeForObjectIDClass setObject:store forKey:NSStringFromClass(objectIDClass)];
    [_stores addObject:store];
    [_objectTypeClasses addObject:objectTypeClass];
    [_objectIDClasses addObject:objectIDClass];
}


#pragma mark - NWSStore

- (NWSObjectID *)identifierWithType:(NWSObjectType *)type primaryPathsAndValues:(NSArray *)pathsAndValues create:(BOOL)create
{
    NWSStore *store = [_storeForObjectTypeClass objectForKey:NSStringFromClass(type.class)];
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
        NWSStore *store = [_storeForObjectIDClass objectForKey:NSStringFromClass(identifier.class)];
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
        NWSStore *store = [_storeForObjectIDClass objectForKey:NSStringFromClass(identifier.class)];
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
        NWSStore *store = [_storeForObjectIDClass objectForKey:NSStringFromClass(identifier.class)];
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
        NWSStore *store = [_storeForObjectIDClass objectForKey:NSStringFromClass(identifier.class)];
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
        NWSStore *store = [_storeForObjectIDClass objectForKey:NSStringFromClass(identifier.class)];
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
        NWSStore *store = [_storeForObjectIDClass objectForKey:NSStringFromClass(identifier.class)];
        NWLogWarnIfNot(store, @"No store for object id: %@", identifier);
        return [store referenceForIdentifier:identifier];
    }
}

- (NWSObjectID *)identifierForObject:(id)object
{
    for (NSString *type in _storeForObjectTypeClass) {
        Class c = NSClassFromString(type);
        if ([c supports:object]) {
            NWSStore *store = [_storeForObjectTypeClass objectForKey:type];
            return [store identifierForObject:object];
        }
    }
    NWLogWarn(@"No object type matches object: %@", object);
    return nil;
}

- (NWSObjectType *)typeFromString:(NSString *)string
{
    for (NWSStore *store in _stores) {
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
    for (NSUInteger i = 0; i < _stores.count; i++) {
        NWSStore *store = [_stores objectAtIndex:i];
        Class typeClass = [_objectTypeClasses objectAtIndex:i];
        Class idClass = [_objectIDClasses objectAtIndex:i];
        [result addStore:[store beginTransaction] objectTypeClass:typeClass objectIDClass:idClass];
    }
    return result;
}

- (void)mergeTransaction:(NWSMultiStore *)store
{
    NWLogWarnIfNot([store isKindOfClass:NWSMultiStore.class], @"Multi store can only merge with multi store.");
    if (store.stores.count == _stores.count) {
        for (NSUInteger i = 0; i < _stores.count; i++) {
            [[_stores objectAtIndex:i] mergeTransaction:[store.stores objectAtIndex:i]];
        }
    } else {
        NWLogWarn(@"Multi stores should have equal number of sub-stores: %i %i", (int)_stores.count, (int)store.stores.count);
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p #stores:%u>", NSStringFromClass(self.class), self, (int)_stores.count];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"multi-store" readable:prefix];
}


#if DEBUG

- (NSArray *)allObjects
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NWSStore *store in _stores) {
        [result addObjectsFromArray:[store allObjects]];
    }
    return result;
}

#endif


@end
