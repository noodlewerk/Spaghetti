//
//  NWSBasicStore.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSBasicStore.h"
#import "NWAbout.h"
#import "NWSClassObjectType.h"
#import "NWSMemoryObjectID.h"
#import "NWSArrayObjectID.h"
#import "NWSPath.h"
#import "NWSPolicy.h"
#import "NWSObjectReference.h"
//#include "NWSLCore.h"


@implementation NWSBasicStore {
    NSMutableArray *_objects;
}


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        _objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObject:(NSObject *)object
{
    [_objects addObject:object];
}


#pragma mark - Store

- (NWSObjectID *)identifierWithType:(NWSObjectType *)type primaryPathsAndValues:(NSArray *)pathsAndValues create:(BOOL)create
{
    // NOTE: no restrictions on type, unless create is YES
    NWSLogWarnIfNot(pathsAndValues.count || create, @"Expecting pathsAndValues or create");
    
    // search for object in internal data store
    if (pathsAndValues.count) {
        for (NSObject *object in _objects) {
            if ([type matches:object]) {
                BOOL match = YES;
                for (NSUInteger i = 1; i < pathsAndValues.count && match; i+=2) {
                    NWSPath *path = pathsAndValues[i-1];
                    id value = pathsAndValues[i];
                    id v = [object valueForPath:path];
                    if (v != value && ![v isEqual:value]) {
                        match = NO;
                    }
                }
                if (match) {
                    return [[NWSMemoryObjectID alloc] initWithObject:object];
                }
            }
        }
    }

    // no object found
    if (create) {
        NWSLogWarnIfNot(_objects.count != 10, @"Basic store is not well suited for 'large' amounts of objects");
        NWSLogWarnIfNot([type isKindOfClass:NWSClassObjectType.class], @"parameter 'type' should be a NWSClassObjectType");
        id object = [[((NWSClassObjectType *)type).clas alloc] init];
        [_objects addObject:object];
        NWSObjectID *identifier = [[NWSMemoryObjectID alloc] initWithObject:object];
        return identifier;
    }
    
    return nil;
}

- (id)attributeForIdentifier:(NWSMemoryObjectID *)identifier path:(NWSPath *)path
{
    NWSLogWarnIfNot([identifier isKindOfClass:NWSMemoryObjectID.class], @"parameter 'identifier' should be a NWSMemoryObjectID");
    return [identifier.object valueForPath:path];
}

- (NWSMemoryObjectID *)relationForIdentifier:(NWSMemoryObjectID *)identifier path:(NWSPath *)path
{
    NWSLogWarnIfNot([identifier isKindOfClass:NWSMemoryObjectID.class], @"parameter 'identifier' should be a NWSMemoryObjectID");
    NSObject *object = [identifier.object valueForPath:path];
    NWSMemoryObjectID *result = [[NWSMemoryObjectID alloc] initWithObject:object];
    return result;
}

- (id)objectWithIdentifier:(NWSObjectID *)identifier baseStore:(NWSStore *)baseStore
{
    if ([identifier isKindOfClass:NWSMemoryObjectID.class]) {
        NWSMemoryObjectID *i = (NWSMemoryObjectID *)identifier;
        return i.object;
    } else if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NSArray *identifiers = ((NWSArrayObjectID *)identifier).identifiers;
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:identifiers.count];
        for (id i in identifiers) {
            id object = [self objectWithIdentifier:i baseStore:baseStore];
            if (object) {
                [result addObject:object];
            } else {
                NWSLogWarn(@"Unable to add nil to object array (%@)", i);
            }
        }
        return result;
    } else if (baseStore) {
        return [baseStore referenceForIdentifier:identifier];
    } else {
        NWSLogWarn(@"Identifier type %@ not supported (and base-store is nil)", identifier.class);
    }
    return nil;    
}

- (void)setAttributeForIdentifier:(NWSObjectID *)identifier value:(id)value path:(NWSPath *)path
{
    NSObject *object = [self objectWithIdentifier:identifier baseStore:nil];
    NSObject *current = [object valueForPath:path];
    // only assign if changed
    if (value != current && ![value isEqual:current]) {
        [object setValue:value forPath:path];
    }
}

- (void)setRelationForIdentifier:(NWSObjectID *)identifier value:(NWSObjectID *)value path:(NWSPath *)path policy:(NWSPolicy *)policy baseStore:(NWSStore *)baseStore
{
    NSObject *object = [self objectWithIdentifier:identifier baseStore:nil];
    NSObject *new = [self objectWithIdentifier:value baseStore:baseStore];
    NSObject *current = [object valueForPath:path];
    // only assign if changed
    if (new != current && ![new isEqual:current]) {
        if (policy.type == kNWSPolicyReplace) {
            [object setValue:new forPath:path];
        } else {
            NWSLogWarn(@"Basic store only supports replace policy");
        }
    }
}

- (void)deleteObjectWithIdentifier:(NWSMemoryObjectID *)identifier
{
    id object = identifier.object;
    NSUInteger index = [_objects indexOfObject:object];
    if (index != NSNotFound) {
        [_objects removeObjectAtIndex:index];
    }
}

- (NWSObjectReference *)referenceForIdentifier:(NWSObjectID *)identifier
{
    id object = [self objectWithIdentifier:identifier baseStore:nil];
    return [[NWSObjectReference alloc] initWithObject:object];
}

- (NWSObjectID *)identifierForObject:(id)object
{
    return [[NWSMemoryObjectID alloc] initWithObject:object];
}

- (NWSObjectType *)typeFromString:(NSString *)string
{
    Class clas = NSClassFromString(string);
    if (clas) {
        return [[NWSClassObjectType alloc] initWithClass:clas];
    }
    return nil;
}


#pragma mark - Transaction management

- (NWSStore *)beginTransaction
{
    return self;
}

- (void)mergeTransaction:(NWSStore *)store
{
    // noop
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p #internal:%u>", NSStringFromClass(self.class), self, (int)_objects.count];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"basic-store" about:prefix];
}


#if DEBUG

- (NSArray *)allObjects
{
    return _objects;
}

#endif

@end
