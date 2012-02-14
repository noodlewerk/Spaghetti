//
//  NWSTransform.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@class NWSMappingContext;

/**
 * Abstract representation of a function that operates on any value given a mapping context.
 *
 * @see NWSMappingContext
 */
@interface NWSTransform : NSObject

/** @name Transforming */

/**
 * Forward transform value given a mapping context.
 * @param value Any value that fits the implementing class.
 * @param context The context that is used for mapping the root.
 * @see reverse:context:
 */
- (id)transform:(id)value context:(NWSMappingContext *)context;

/**
 * Inverse transform value given a mapping context.
 * @param value Any value that fits the implementing class.
 * @param context The context that is used for mapping the root.
 * @see transform:context:
 */
- (id)reverse:(id)value context:(NWSMappingContext *)context;

/** @name Convenience */

/**
 * Returns a new transform which is a composition of this and a given transform.
 * @param transform The transform combined after this transform.
 * @see NWSCompositeTransform
 */
- (NWSTransform *)composeWith:(NWSTransform *)transform;

@end
