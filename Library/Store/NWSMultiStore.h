//
//  NWSMultiStore.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSStore.h"


/**
 * Groups multiple stores together as a single store.
 *
 * The multi-store aggregates an array of stores by forwarding messages to the store that has a matching objectTypeClass or objectIDClass.
 *
 * @see NWSStore
 * @see NWSCoreDataStore
 * @see NWSBasicStore
 */
@interface NWSMultiStore : NWSStore

/**
 * The collection of stores this multi-store can choose from.
 */
@property (nonatomic, strong, readonly) NSArray *stores;

/**
 * Adds a store that handles object corresponding to a given type class en identifier class.
 * @param store The store added.
 * @param objectTypeClass Subclass of NWSObjectType class.
 * @param objectIDClass Subclass of NWSObjectID class.
 * @see NWSObjectType
 * @see NWSObjectID
 */
- (void)addStore:(NWSStore *)store objectTypeClass:(Class)objectTypeClass objectIDClass:(Class)objectIDClass;

@end
