//
//  NWSStringToNumberTransform.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
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

/**
 * Parses the string into an NSNumber without using NSNumberFormatter.
 */
+ (NSNumber *)numberForString:(NSString *)string;

@end
