//
//  NWSBasicStore.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSStore.h"

/**
 * A miminal implementation of an in-memory store based on an array of objects.
 *
 * Like the name suggests, the basic store is a fairly minimal implementation of a fully functional store. Due to it's simplicity, the basic store has poor performance characteristics. Therefore the basic store primarily functions as a reference implementation and is generally not suited for production environments. If you only need a store to 'glue' core data objects, then use the NWSAmnesic store. If you need a fully functionaly in-memory store, then use the NWSIndexedStore.
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
