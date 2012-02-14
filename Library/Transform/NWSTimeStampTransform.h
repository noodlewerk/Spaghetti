//
//  NWSTimeStampTransform.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"

/**
 * Transforms a POSIX timestamp in seconds to an NSDate.
 *
 * @see NWSTransform
 */
@interface NWSTimeStampTransform : NWSTransform

/**
 * Returns a timestamp transform. This is the preferred way of getting an instance.
 * @see NWSDateFormatterTransform
 */
+ (NWSTimeStampTransform *)shared;

@end
