//
//  NWStats.h
//  NWTools
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Provides basic statistical information (average, variance) of a single variable.
 */
@interface NWStats : NSObject

/**
 * The number of times a value was added to the dataset.
 */
@property (nonatomic, assign, readonly) long int count;

/**
 * The sum of all values added divided by the count.
 */
@property (nonatomic, assign, readonly) double average;

/**
 * The average squared-value minus the squared-average.
 */
@property (nonatomic, assign, readonly) long double variance;

/**
 * The square root of the variance.
 */
@property (nonatomic, assign, readonly) double deviation;

/**
 * Add a new value to the data set.
 * @param value The new value.
 */
- (void)count:(double)value;

@end