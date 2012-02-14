//
//  NWSCompositeTransform.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"

/**
 * A sequence of sub-transforms combined into one.
 *
 * @see NWSTransform
 */
@interface NWSCompositeTransform : NWSTransform

/**
 * The sub-transforms that are applied in order to input values.
 */
@property (nonatomic, readonly) NSArray *transforms;

/**
 * Inits the composite transform.
 * @param transforms The sub-transforms that are applied in order to input values.
 */
- (id)initWithTransforms:(NSArray *)transforms;

@end
