//
//  NWSBlockTransform.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"


/**
 * A transform based on a block implementation.
 *
 * @see NWSTransform
 */
@interface NWSBlockTransform : NWSTransform

/**
 * Block used for forward transform.
 */
@property (nonatomic, copy) id(^transformBlock)(id value, NWSMappingContext* context);

/**
 * Block used for reverse transform.
 */
@property (nonatomic, copy) id(^reverseBlock)(id value, NWSMappingContext* context);

/**
 * Init with only a forward transform block, reverse is nil.
 * @param transformBlock The forward transform block.
 */
- (id)initWithBlock:(id(^)(id value, NWSMappingContext* context))transformBlock;

/**
 * Init with both a forward and reverse transform block.
 * @param transformBlock The forward transform block.
 * @param reverseBlock The reverse transform block.
 */
- (id)initWithTransformBlock:(id(^)(id value, NWSMappingContext* context))transformBlock reverseBlock:(id(^)(id value, NWSMappingContext* context))reverseBlock;

@end
