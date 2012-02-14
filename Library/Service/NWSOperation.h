//
//  NWSOperation.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

/**
 * Something that can be cancelled.
 *
 * The main purpose of this protocol is to allow an object, like an operation, to indicate that it can be cancelled. This in turn allows management of these operations life time. An example of such management is NWSOperationOwner, which maintains a collection of operations and allows mass-canceling.
 *
 * For a more practical explanation, please refer to NWSOperationOwner.
 *
 * @see NWSOperationOwner
 */
@protocol NWSOperation <NSObject>

/**
 * Cancels this operation. May be invoked multiple times from any thread.
 */
- (void)cancel;

@end


/**
 * Owner of a collection of operations that can be cancelled all at once.
 *
 * The operation owner allows collective canceling of operations. When you have an operation that might run for a long time, maybe too long, you need some supervising object to take care of its life time. In stead of letting a view controller keep track of these, which easily gets messy, an operation owner can collect all these operations, migrating the need to manage multiple operations to managing only one: this owner.
 *
 * For example, we have a view controller that spawns http connection. One on load, and one for every button pressed. As long a this view controller is visible, all connections can run without trouble, but as soon as the view disappears, or the view controller unloads, these connections need to be cancelled. By adding all connections to an operation owner, you can simply call cancelAllOperations in the viewWillDisappear: and you're done.
 *
 * @see NWSOperation
 */
@interface NWSOperationOwner : NSObject<NWSOperation>

/**
 * The collection of operations owned.
 */
@property (nonatomic, strong, readonly) NSArray *operations;

/** @name Initializing */

/**
 * Inits the owner without parent, so take care of it.
 */
- (id)init;

/**
 * Inits the owner and adds it to a parent owner.
 * @param parent An optional parent owner that takes ownership over this one.
 */
- (id)initWithParent:(NWSOperationOwner *)parent;

/** @name Managing operations */

/**
 * Adds an operation to be owned by this owner.
 * @param operation The operation to be owned.
 */
- (void)addOperation:(id<NWSOperation>)operation;

/**
 * Iterates through all added operations and calls cancel.
 * @see [NWSOperation cancel]
 */
- (void)cancelAllOperations;

@end
