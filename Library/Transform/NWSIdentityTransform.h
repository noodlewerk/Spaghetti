//
//  NWSIdentityTransform.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"


/**
 * This is the trivial transform that maps every value on that value, simply passing it on.
 *
 * Although the identity transform doesn't do anything, it can be useful in cases where a transform object is required, but no actual transformation needed.
 *
 * @see NWSTransform
 */
@interface NWSIdentityTransform : NWSTransform

/**
 * Since all identity transforms are identical, this is the preferred way of getting an instance.
 */
+ (NWSIdentityTransform *)shared;

@end
