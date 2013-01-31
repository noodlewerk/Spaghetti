//
//  NWSOrderKeyTransform.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"

/**
 * A transform that ignores the input value and instead returns an order key path based on the context's `indexInArray`. This transform can be used to set an order key to a certain attribute in a mapping.
 *
 * @param NWSMapping
 */
@interface NWSOrderKeyTransform : NWSTransform

/** @name Accessing properties */

/**
 * The first order key value.
 */
@property (nonatomic, assign) NSInteger begin;

/**
 * The interval between two successive order keys.
 */
@property (nonatomic, assign) NSInteger step;

/** @name Initializing */

/**
 * Inits this order transform with given properties.
 * @param begin The first order value in sequence.
 * @param step The interval between successive order values.
 */
- (id)initWithBegin:(NSInteger)begin step:(NSInteger)step;

/**
 * Returns the default order key transform with `begin = 0` and `step = 1`.
 *
 * NB: Do not modify this instance!
 */
+ (NWSOrderKeyTransform *)shared;

@end
