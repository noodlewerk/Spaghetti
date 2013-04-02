//
//  NWSAmnesicStore.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSStore.h"

/**
 * A basic in-memory store, similar to the memory store, but without any internal object collection.
 *
 * The amnesic store provides all the means to get and set attributes and relations of in-memory objects. It however does not keep a reference to the objects created and therefore does not support any object fetching or primary key referencing. This makes the amnesic store very efficient and a likely choice for the temporary mapping of data in memory.
 *
 * This allows it to function as glue between the more powerful Core Data store and other parts of the framework. For example, if A and C subclass NSManagedObject, but B does not, mapping the following with only a Core Data store, requires custom transforms and special care-taking of the data in "b":
 *
 *    {"a":{"b":{"c":{}}}}
 *
 * However, by introducing a basic store to handle "b", we can use standard mappings that will put "b" in the basic store and create cross-store references from "a" to "b" and "b" to "c".
 */
@interface NWSAmnesicStore : NWSStore

+ (NWSAmnesicStore *)shared;

@end
