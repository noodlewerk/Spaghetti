//
//  NWSCoreDataStore.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSCoreDataStore.h"
#import "NWAbout.h"
#import "NWSManagedObjectID.h"
#import "NWSArrayObjectID.h"
#import "NWSEntityObjectType.h"
#import "NWSPolicy.h"
#import "NWSKeyPathPath.h"
#import "NWSSingleKeyPath.h"
#import "NWSObjectReference.h"
#include "NWLCore.h"


//#define DEBUG_CACHE_CHECK
@interface NWSStoreCacheKey : NSObject <NSCopying>
@property (nonatomic, strong) NSEntityDescription *entity;
@property (nonatomic, strong) NSArray *pathsAndValues;
- (id)initWithEntity:(NSEntityDescription *)entity primaryPathsAndValues:(NSArray *)pathsAndValues;
@end



@interface NWSCoreDataStore()
@property (nonatomic, strong) NSMutableArray *references;
@end

@implementation NWSCoreDataStore {
    NSMutableDictionary *_cache;
    NSMutableArray *_toBeDeleted;
}


#pragma mark - Object life cycle

- (id)initWithContext:(NSManagedObjectContext *)context queue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        _context = context;
        _queue = queue;
        _references = [[NSMutableArray alloc] init];
        _cache = [[NSMutableDictionary alloc] init];
        _toBeDeleted = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - Store

- (NSManagedObjectID *)fetchWithEntity:(NSEntityDescription *)entity primaryPathsAndValues:(NSArray *)pathsAndValues
{
    // create predicates from primary properties (paths and values)
    NWLogWarnIfNot(pathsAndValues.count % 2 == 0, @"Every path needs a value");
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:pathsAndValues.count / 2];
    for (NSUInteger i = 1; i < pathsAndValues.count; i += 2) {
        NWSPath *path = pathsAndValues[i - 1];
        id value = pathsAndValues[i];
        NSString *pathString = nil;
        if ([path isKindOfClass:NWSSingleKeyPath.class]) {
            pathString = [(NWSSingleKeyPath *)path key];
        } else if ([path isKindOfClass:NWSKeyPathPath.class]) {
            pathString = [(NWSKeyPathPath *)path keyPath];
        }
        if (pathString.length && value) {
            NSPredicate *predicate = [[NSComparisonPredicate alloc] initWithLeftExpression:[NSExpression expressionForKeyPath:pathString] rightExpression:[NSExpression expressionForConstantValue:value] modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
            [predicates addObject:predicate];
        } else {
            NWLogWarn(@"Unable to create predicate for path '%@' and value '%@'", path, value);
        }
    }
    // set up fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    request.resultType = NSManagedObjectIDResultType;
    // perform fetch
    NSError *error = nil;
    NSArray *results = [_context executeFetchRequest:request error:&error];
    NWLogWarnIfError(error);
    NWLogWarnIfNot(results, @"Expected fetch request to return non-nil");
    if (results.count) {
        NWLogWarnIfNot(results.count == 1, @"Multiple objects match primary properties");
        NSManagedObjectID *identifier = results.lastObject;
        return identifier;
    }
    return nil;
}

- (NSManagedObjectID *)fetchCachedWithEntity:(NSEntityDescription *)entity primaryPathsAndValues:(NSArray *)pathsAndValues
{
    NWSStoreCacheKey *key = [[NWSStoreCacheKey alloc] initWithEntity:entity primaryPathsAndValues:pathsAndValues];
    NSManagedObjectID *result = _cache[key];
    if (!result) {
        result = [self fetchWithEntity:entity primaryPathsAndValues:pathsAndValues];
        if (result) {
            _cache[key] = result;
        }
#ifdef DEBUG_CACHE_CHECK
    } else {
        NSManagedObjectID *c = [self fetchWithEntity:entity primaryPathsAndValues:pathsAndValues];
        NWLogWarnIfNot([result isEqual:c] && [result.URIRepresentation.absoluteString isEqualToString:c.URIRepresentation.absoluteString], @"");
#endif
    }
    return result;
}

- (NWSObjectID *)identifierWithType:(NWSEntityObjectType *)type primaryPathsAndValues:(NSArray *)pathsAndValues create:(BOOL)create
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"identifierWithType: %@ %@ %@", type, pathsAndValues, create ? @"create" : @"do-not-create");
    NWLogWarnIfNot(pathsAndValues.count || create, @"So I should not find and should not create an object?");
    NWLogWarnIfNot([type isKindOfClass:NWSEntityObjectType.class], @"");

    // extract entity description
    NSEntityDescription *entity = type.entity;
    NWLogWarnIfNot(entity, @"No entity found in object type: %@", type);

    if (pathsAndValues.count) {
        NSManagedObjectID *identifier = [self fetchCachedWithEntity:entity primaryPathsAndValues:pathsAndValues];
        if (identifier) {
            return [[NWSManagedObjectID alloc] initWithID:identifier];
        }
    }
    
    // not found, so create
    if (create) {
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:_context];
        // assign new object its primary values
        for (NSUInteger i = 1; i < pathsAndValues.count; i+=2) {
            NWSPath *path = pathsAndValues[i-1];
            id value = pathsAndValues[i];
            [object setValue:value forPath:path];
        }
        return [[NWSManagedObjectID alloc] initWithID:object.objectID];
    }
    
    return nil;
}

- (id)attributeForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"attributeForIdentifier: %@ %@", identifier, path);
    if ([identifier isKindOfClass:NWSManagedObjectID.class]) {
        NWSManagedObjectID *i = (NWSManagedObjectID *)identifier;
        NSObject *object = [_context objectWithID:i.ID];
        id result = [object valueForPath:path];
        // TODO: why is this?
        if ([result isKindOfClass:NSSet.class]) {
            NWLogWarn(@"should never happen for attribute");
            result = [(NSSet *)result allObjects];
        }
        return result;
    } else {
        NWLogWarn(@"identifier not supported: %@", identifier);
    }
    return nil;
}

- (NWSObjectID *)relationForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"relationForIdentifier: %@ %@", identifier, path);
    if ([identifier isKindOfClass:NWSManagedObjectID.class]) {
        NWSManagedObjectID *i = (NWSManagedObjectID *)identifier;
        NSObject *object = [_context objectWithID:i.ID];
        id value = [object valueForPath:path];
        if ([value isKindOfClass:NSSet.class]) {
            NSSet *set = (NSSet *)value;
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:set.count];
            for (NSManagedObject *o in set) {
                [array addObject:[[NWSManagedObjectID alloc] initWithID:o.objectID]];
            }
            NWSArrayObjectID *result = [[NWSArrayObjectID alloc] initWithIdentifiers:array];
            return result;
        }
        NWSManagedObjectID *result = [[NWSManagedObjectID alloc] initWithID:[(NSManagedObject *)value objectID]];
        return result;
    } else {
        NWLogWarn(@"type not supported");
    }
    return nil;
}

- (void)setAttributeForIdentifier:(NWSObjectID *)identifier value:(id)value path:(NWSPath *)path
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"setAttributeForIdentifier: %@, %@ = %@", identifier, path, value);
    if ([identifier isKindOfClass:NWSManagedObjectID.class]) {
        NWSManagedObjectID *i = (NWSManagedObjectID *)identifier;
        NSObject *object = [_context objectWithID:i.ID];
        NSObject *current = [object valueForPath:path];
        // only assign if changed
        if (value != current && ![value isEqual:current]) {
            [object setValue:value forPath:path];
        }
    } else {
        NWLogWarn(@"type not supported");
    }
}

- (id)objectWithIdentifier:(NWSObjectID *)identifier baseStore:(NWSStore *)baseStore
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"objectWithIdentifier: %@", identifier);
    if ([identifier isKindOfClass:NWSManagedObjectID.class]) {
        NWSManagedObjectID *i = (NWSManagedObjectID *)identifier;
        NSManagedObject *result = [_context objectWithID:i.ID];
        NWLogWarnIfNot(result, @"No object with managed object ID");
        return result;
    } else if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NSArray *identifiers = ((NWSArrayObjectID *)identifier).identifiers;
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:identifiers.count];
        for (NWSObjectID *i in identifiers) {
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
        NWLogWarn(@"type not supported");
    }
    return nil;
}

- (void)setRelationForIdentifier:(NWSManagedObjectID *)identifier value:(NWSObjectID *)value path:(NWSPath *)path policy:(NWSPolicy *)policy baseStore:(NWSStore *)baseStore
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"setRelationForIdentifier: %@, %@ = %@ (%@)", identifier, path, value, policy);
    if ([identifier isKindOfClass:NWSManagedObjectID.class]) {
        NSObject *object = [_context objectWithID:identifier.ID];
        // TODO: do we need to fetch the object, can't we just assign based on NSManagedObjectID?
        id valueObject = value ? [self objectWithIdentifier:value baseStore:baseStore] : nil;
        NWLogWarnIfNot(policy, @"Expecting policy to be non-nil");
        if (policy.toMany) {
            NWLogWarnIfNot([valueObject isKindOfClass:NSArray.class], @"To many setter expects array");
            NSArray *valueArray = (NSArray *)valueObject;
            NSSet *current = [object valueForPath:path];
            NSSet *new = nil;
            if (policy.type == kNWSPolicyAppend) {
                new = [current setByAddingObjectsFromArray:valueArray];
            } else {
                new = [NSSet setWithArray:valueArray];
            }
            // only assign if changed
            if (![current isEqualToSet:new]) {
                [object setValue:new forPath:path];
                if (policy.type == kNWSPolicyDelete) {
                    // delete current ones
                    NSMutableSet *delete = [NSMutableSet setWithSet:current];
                    [delete minusSet:new];
                    for (NSManagedObject *o in delete) {
                        NWSManagedObjectID *ID = [[NWSManagedObjectID alloc] initWithID:o.objectID];
                        [self deleteObjectWithIdentifier:ID];
                    }
                }
            }
        } else {
            NSManagedObject *current = [object valueForPath:path];
            NSManagedObject *new = (NSManagedObject *)valueObject;
            // only assign if changed
            if (new != current && ![new isEqual:current]) {
                if (policy.type == kNWSPolicyReplace || policy.type == kNWSPolicyDelete) {
                    [object setValue:new forPath:path];
                    if (policy.type == kNWSPolicyDelete && current) {
                        // delete current one
                        NWSManagedObjectID *ID = [[NWSManagedObjectID alloc] initWithID:current.objectID];
                        [self deleteObjectWithIdentifier:ID];
                    }                    
                } else {
                    NWLogWarn(@"Only replace or delete policy supported on to-one relations");                        
                }
            }
        }
    } else {
        NWLogWarn(@"identifier type not supported: %@", identifier);
    }
}

- (void)deleteObjectWithIdentifier:(NWSManagedObjectID *)identifier
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"deleteObjectWithIdentifier: %@", identifier);
    if ([identifier isKindOfClass:NWSManagedObjectID.class]) {
        [_toBeDeleted addObject:identifier.ID];
    } else {
        NWLogWarn(@"identifier type not supported: %@", identifier);
    }
}

- (NWSObjectReference *)referenceForIdentifier:(NWSObjectID *)identifier
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"referenceForIdentifier: %@", identifier);
    id object = [self objectWithIdentifier:identifier baseStore:nil];
    NWSObjectReference *result = [[NWSObjectReference alloc] initWithObject:object];
    [_references addObject:result];
    return result;
}

- (NWSObjectID *)identifierForObject:(NSManagedObject *)object
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"identifierForObject: %@", object);
    if ([object isKindOfClass:NSManagedObject.class]) {
        return [[NWSManagedObjectID alloc] initWithID:object.objectID];
    } else if (object) {
        NWLogWarn(@"Core data store can only make identifier for managed objects");
    }
    return nil;
}

- (NWSObjectType *)typeFromString:(NSString *)string
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NSEntityDescription *entity = [NSEntityDescription entityForName:string inManagedObjectContext:_context];
    if (entity) {
        return [[NWSEntityObjectType alloc] initWithEntity:entity];
    }
    return nil;
}


#pragma mark - Transaction management

- (NWSStore *)beginTransaction
{
    NSManagedObjectContext *context = _context;
    switch (_transactionType) {
        case kNWSTransactionTypeNewContext: {
            BOOL hasPersistentStore = _context.persistentStoreCoordinator.persistentStores.count > 0;
            if (hasPersistentStore) {
                // can be called from any (background) thread
                context = [[NSManagedObjectContext alloc] init];
                context.undoManager = nil;
                context.persistentStoreCoordinator = _context.persistentStoreCoordinator;
            } else {
                NWLogWarn(@"kNWSTransactionTypeNewContext requires a persistent store, using kNWSTransactionTypeCurrentContext instead.");
            }
        } break;
        case kNWSTransactionTypeCurrentContext: break;
    }
    return [[NWSCoreDataStore alloc] initWithContext:context queue:NSOperationQueue.currentQueue];
}

- (void)cleanup
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    NWLogInfo(@"cleanup");
    
    // apply all deletes
    for (NSManagedObjectID *i in _toBeDeleted) {
        NSManagedObject *object = [_context objectWithID:i];
        [_context deleteObject:object];
    }
}

/**
 * Migrates references of temp-store object to base-store objects. This allows inter-store references to be updated after temp object have been saved.
 * @param baseStore The underlying store to which we're migrating.
 */
- (void)migrateReferencesToStore:(NWSCoreDataStore *)baseStore
{
    NWLogWarnIfNot(_queue == NSOperationQueue.currentQueue, @"Core data store should be invoked on one queue: %@", _queue);
    
    // remove modified references from the temp-store
    NSArray *refs = [[NSArray alloc] initWithArray:_references];
    [_references removeAllObjects];  
   
    // migrate pending references
    for (NWSObjectReference *reference in refs) {
        id object = reference.object;
        // migrate reference to an identifier
        reference.object = [object mapWithBlock:^NSManagedObjectID *(NSManagedObject *o) {
            NWLogWarnIfNot(!o.isFault, @"Expecting object to not be fault");
            NSManagedObjectID *identifier = o.objectID;
            return identifier;              
        }];
    }
    
    // add modified references to the base-store
    void(^finishMigrateBlock)(void) = ^{
        for (NWSObjectReference *reference in refs) {
            // migrate identifier to a reference
            id identifier = reference.object;
            reference.object = [identifier mapWithBlock:^NSManagedObject *(NSManagedObjectID *i) {
                return [baseStore.context objectWithID:i];
            }];
        }
        [baseStore.references addObjectsFromArray:refs];
    };
    // TODO: waiting, is it safe?
    if (baseStore.queue != NSOperationQueue.currentQueue) {
        [baseStore.queue addOperations:@[[NSBlockOperation blockOperationWithBlock:[finishMigrateBlock copy]]] waitUntilFinished:YES];
    } else {
        finishMigrateBlock();
    }
}

- (void)mergeTransaction:(NWSCoreDataStore *)tempStore
{
    NWLogWarnIfNot([self isKindOfClass:NWSCoreDataStore.class], @"Core data store can only merge with other core data store");
    NWLogWarnIfNot(tempStore.queue == NSOperationQueue.currentQueue, @"Merge should be invoked on temp queue: %@", tempStore.queue);
    
    // signal temp store it's going away
    [tempStore cleanup];
    
    switch (_transactionType) {
        case kNWSTransactionTypeNewContext: {
            // get notified when safe is done
            NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
            id observer = [center addObserverForName:NSManagedObjectContextDidSaveNotification object:tempStore.context queue:_queue usingBlock:^(NSNotification *notification) {
                // update fetched result controllers, see also: http://www.mlsite.net/blog/?p=518
                NSArray* updates = [(notification.userInfo)[@"updated"] allObjects];
                for (NSManagedObject *o in updates.reverseObjectEnumerator) {
                    id object = [_context objectWithID:o.objectID];
                    [object willAccessValueForKey:nil];
                }
                [_context mergeChangesFromContextDidSaveNotification:notification];
            }];
            // perform save
            NSError *error = nil;
            BOOL saved = [tempStore.context save:&error];
            NWLogWarnIfError(error);
            NWLogWarnIfNot(saved, @"Failed to save temporary context");
            [center removeObserver:observer];
        } break;
        case kNWSTransactionTypeCurrentContext: break;
    }

    // migrate references
    [tempStore migrateReferencesToStore:self];
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p context:%@>", NSStringFromClass(self.class), self, _context];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"core-data-store" about:prefix];
}


#if DEBUG

- (NSArray *)allObjects
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *entities = _context.persistentStoreCoordinator.managedObjectModel.entities;
    for (NSEntityDescription *entity in entities) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = entity;
        NSError *error = nil;
        NSArray *results = [_context executeFetchRequest:request error:&error];
        NWLogWarnIfError(error);
        [result addObjectsFromArray:results];
    }
    return result;
}

#endif

@end



@implementation NWSStoreCacheKey

- (id)initWithEntity:(NSEntityDescription *)entity primaryPathsAndValues:(NSArray *)pathsAndValues
{
    self = [super init];
    if (self) {
        _entity = entity;
        _pathsAndValues = pathsAndValues;
    }
    return self;
}

- (NSUInteger)hash
{
    NSUInteger result = 7932973320 + _entity.hash;
    for (id i in _pathsAndValues) {
        result = 31 * result + [i hash];
    }
    return result;
}

- (BOOL)isEqual:(NWSStoreCacheKey *)key
{
    return self == key || (self.class == key.class && [self.entity isEqual:key.entity] && [self.pathsAndValues isEqualToArray:key.pathsAndValues]);
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
