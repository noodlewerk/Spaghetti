//
//  NWSObjectReference.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A reference is a one-element container, a pointer to an object.
 *
 * Because objects in store can be moved to a different memory address, inter-store relations do not point to the object directly, but use a reference. When an object moves, its references are migrated by the store that owns the object.
 *
 * For example, an arbitrary object B in a NWSBasicStore can point to a managed object C in a NWSCoreDataStore. While C is not yet saved to disk, it has a different memory address than after the context has been saved. By holding a reference, A can always get to the right address of C by using a reference that is maintained by the store of C.
 */
@interface NWSObjectReference : NSObject

/**
 * The current memory address this reference is pointing to.
 */
@property (nonatomic, strong) id object;

/**
 * Returns a new reference to an object.
 * @param object The object this reference should point to.
 */
- (id)initWithObject:(id)object;

/**
 * Returns the referred object by taking all references out.
 */
- (id)dereference;

@end


@interface NSObject (MapAdditions)

- (id)mapWithBlock:(id(^)(id))block;

@end
