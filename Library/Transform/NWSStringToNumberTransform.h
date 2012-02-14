//
//  NWSStringToNumberTransform.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"

/**
 * Transforms a string representation of a number (integer or floating point) to an instance of NSNumber, using NSNumberFormatterDecimalStyle.
 *
 * @see NWSTransform
 */
@interface NWSStringToNumberTransform : NWSTransform

/**
 * Since all string-to-number transforms are identical, this is the preferred way of getting an instance.
 */
+ (NWSStringToNumberTransform *)shared;

@end
