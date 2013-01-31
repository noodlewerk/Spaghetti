//
//  NWSBlockTransform.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"


typedef id(^NWSTransformBlock)(id value, NWSMappingContext* context);

/**
 * A transform based on a block implementation.
 *
 * @see NWSTransform
 */
@interface NWSBlockTransform : NWSTransform

/**
 * Block used for forward transform.
 */
@property (nonatomic, copy) NWSTransformBlock transformBlock;

/**
 * Block used for reverse transform.
 */
@property (nonatomic, copy) NWSTransformBlock reverseBlock;

/**
 * Init with only a forward transform block, reverse is nil.
 * @param transformBlock The forward transform block.
 */
- (id)initWithBlock:(NWSTransformBlock)transformBlock;

/**
 * Init with both a forward and reverse transform block.
 * @param transformBlock The forward transform block.
 * @param reverseBlock The reverse transform block.
 */
- (id)initWithTransformBlock:(NWSTransformBlock)transformBlock reverseBlock:(NWSTransformBlock)reverseBlock;

@end
