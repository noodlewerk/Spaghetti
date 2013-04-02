//
//  NWSBasicStore.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSStore.h"


/**
 * An in-memory store that is simply a collection of objects.
 *
 * Like the name suggests, the basic store is a fairly minimal implementation of a fully functional store. This allows it to function as glue between the more powerful Core Data store and other parts of the framework. For example, if A and C subclass NSManagedObject, but B does not, mapping the following with only a Core Data store, requires custom transforms and special care-taking of the data in "b":
 *
 *    {"a":{"b":{"c":{}}}}
 *
 * However, by introducing a basic store to handle "b", we can use standard mappings that will put "b" in the basic store and create cross-store references from "a" to "b" and "b" to "c".
 *
 * Currently, the basic store uses matches: method of NWSObjectType to determine whether an object exists in its internal store. This implies O(N) lookup times on the number of objects in this store. Therefore the basic store is _not_ suited for large amounts of object.
 *
 * @see NWSStore
 * @see NWSCoreDataStore
 * @see NWSMapping
 */
@interface NWSBasicStore : NWSStore

/**
 * Allows for adding an object to the internal store directly.
 * @param object Any object that can be stored in an NSArray and is key-value compliant.
 */
- (void)addObject:(NSObject *)object;

@end
