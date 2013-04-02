//
//  NWSStore.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NWSObjectID, NWSObjectType, NWSPath, NWSPolicy, NWSObjectReference;

/**
 * Represents a repository of objects with identifiers that can be retrieved using object properties and used to get and set values and relations.
 */
@interface NWSStore : NSObject


/** @name Accessing store for mapping*/

/**
 * Returns the identifier of an object with a given type and primary values.
 * @param type The type of the object returned.
 * @param pathsAndValues Array with paths and values that identify a single object.
 * @param create If YES and no object can be found, one will be created.
 */
- (NWSObjectID *)identifierWithType:(NWSObjectType *)type primaryPathsAndValues:(NSArray *)pathsAndValues create:(BOOL)create;

/**
 * Returns the value of an attribute of an object in this store.
 * @param identifier The identifier of this object.
 * @param path The path of this attribute.
 */
- (id)attributeForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path;

/**
 * Returns the value of an relation of an object in this store.
 * @param identifier The identifier of this object.
 * @param path The path of this relation.
 */
- (NWSObjectID *)relationForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path;

/**
 * Assigns a value to an attribute of an object in this store.
 * @param identifier The identifier of this object.
 * @param value The value to be assigned.
 * @param path The path of this relation.
 */
- (void)setAttributeForIdentifier:(NWSObjectID *)identifier value:(id)value path:(NWSPath *)path;

/**
 * Sets a relation of an object in this store.
 * @param identifier The identifier of this object.
 * @param value The value to be set.
 * @param path The path of this relation.
 * @param policy The policy describing how to set.
 * @param baseStore An optional base-store to accommodate cross-store relations.
 */
- (void)setRelationForIdentifier:(NWSObjectID *)identifier value:(NWSObjectID *)value path:(NWSPath *)path policy:(NWSPolicy *)policy baseStore:(NWSStore *)baseStore;

/**
 * Removes an object from this store.
 * @param identifier The identifier of the object to be deleted.
 */
- (void)deleteObjectWithIdentifier:(NWSObjectID *)identifier;


/** @name Accessing store from elsewhere */

/**
 * Returns an object reference given an identifier.
 *
 * This allows for access to the actual objects, instead of only their identifiers.
 * NB: This converts a thread-safe identifier into a possibly thread-bound object, i.e. an NSManagedObject. These object are faulted without store, etc.
 * @param identifier The ID of an object in this store.
 * @see NWSObjectReference
 */
- (NWSObjectReference *)referenceForIdentifier:(NWSObjectID *)identifier;

/**
 * Returns an object of a given type with give primary value.
 *
 * This convenience method allows for fetching objects from the store without having to deal with identifiers and types.
 * @param type The type of the object returned.
 * @param path The primary path.
 * @param value The primary value.
 * @see referenceForIdentifier:
 */
- (id)objectWithType:(NSString *)type primaryPath:(NSString *)path value:(id)value;

/**
 * Returns an identifier for an object.
 *
 * As most store methods use identifiers instead of the actual object, this method provides the means to convert from object to identifier.
 * @param object An object of a type that matches the store.
 */
- (NWSObjectID *)identifierForObject:(id)object;

/**
 * Returns an object type given a string.
 *
 * As the store uses object types internally, this method provides the means to acquire a type based on its name.
 * @param string A string representation of the type, e.g. class or entity name.
 * @see objectWithType:primaryPath:value:
 * @see identifierWithType:primaryPathsAndValues:create:
 */
- (NWSObjectType *)typeFromString:(NSString *)string;


/** @name Starting and merging a transaction */

/**
 * Returns a store to which multiple operations can be performed as a single transaction.
 * 
 * This method marks the start of a transaction. The returned can be accessed in parallel with the current store, for example allowing the mapping of an object to be performed in the background. When the transaction is finished mergeTransaction: should be called.
 * @see mergeTransaction:
 */
- (NWSStore *)beginTransaction;

/**
 * Marks the end of a transaction by merging the transaction store back into this store.
 * @param store The transaction store.
 * @see beginTransaction
 */
- (void)mergeTransaction:(NWSStore *)store;


#if DEBUG

- (NSArray *)allObjects;

#endif

@end
