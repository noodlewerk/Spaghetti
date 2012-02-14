//
//  NWSAmnesicStore.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSAmnesicStore.h"
#import "NWSMemoryObjectID.h"
#import "NWSClassObjectType.h"
#import "NWSPath.h"
#import "NWSArrayObjectID.h"
#import "NWSCommon.h"
#import "NWSObjectReference.h"
#import "NWSPolicy.h"


@implementation NWSAmnesicStore


#pragma mark - Object life cycle

+ (NWSAmnesicStore *)shared
{
    static NWSAmnesicStore *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSAmnesicStore alloc] init];
    });
    return result;
}


#pragma mark - Store

- (NWSObjectID *)identifierWithType:(NWSClassObjectType *)type primaryPathsAndValues:(NSArray *)pathsAndValues create:(BOOL)create
{
    NWLogWarnIfNot(pathsAndValues.count == 0, @"Amnesic store does not support primary keys");
    
    // no object found
    if (create) {
        NWLogWarnIfNot([type isKindOfClass:NWSClassObjectType.class], @"parameter 'type' should be a NWSClassObjectType");
        id object = [[type.clas alloc] init];
        NWSObjectID *result = [[NWSMemoryObjectID alloc] initWithObject:object];
        return result;
    } else {
        NWLogWarn(@"Amnesic store only creates objects, it doesn't fetch any because it doesn't have any");
    }
    
    return nil;
}

- (id)attributeForIdentifier:(NWSMemoryObjectID *)identifier path:(NWSPath *)path
{
    NWLogWarnIfNot([identifier isKindOfClass:NWSMemoryObjectID.class], @"parameter 'identifier' should be a NWSMemoryObjectID");
    return [identifier.object valueForPath:path];
}

- (NWSMemoryObjectID *)relationForIdentifier:(NWSMemoryObjectID *)identifier path:(NWSPath *)path
{
    NWLogWarnIfNot([identifier isKindOfClass:NWSMemoryObjectID.class], @"parameter 'identifier' should be a NWSMemoryObjectID");
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
                NWLogWarn(@"Unable to add nil to object array (%@)", i);
            }
        }
        return result;
    } else if (identifier && baseStore) {
        return [baseStore referenceForIdentifier:identifier];
    } else {
        NWLogWarn(@"Identifier type %@ not supported (and base-store is nil)", identifier.class);
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
    NSObject *new = value ? [self objectWithIdentifier:value baseStore:baseStore] : nil;
    NSObject *current = [object valueForPath:path];
    // only assign if changed
    if (new != current && ![new isEqual:current]) {
        if (policy.type == kNWSPolicyReplace) {
            [object setValue:new forPath:path];
        } else {
            NWLogWarn(@"Only replace policy is supported");
        }
    }
}

- (void)deleteObjectWithIdentifier:(NWSMemoryObjectID *)identifier
{
    // Amnesic store does not need to remove objects, cuz it doesn't have them
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
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"amnesic-store" readable:prefix];
}


#if DEBUG

- (NSArray *)allObjects
{
    NWLogWarn(@"Amnesic store does not keep track of objects it creates");
    return nil;
}

#endif


@end
