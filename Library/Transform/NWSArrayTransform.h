//
//  NWSArrayTransform.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"

/**
 * Transforms an array of elements by transforming each element individually into an array of equal size.
 *
 * @see NWSTransform
 */
@interface NWSArrayTransform : NWSTransform

/**
 * The transform that will be applied to each array element.
 */
@property (nonatomic, strong) NWSTransform *transform;

/**
 * Init with a transform.
 * @param transform The transform that will be applied to each array element.
 */
- (id)initWithTransform:(NWSTransform *)transform;

@end
