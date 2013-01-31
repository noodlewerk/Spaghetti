//
//  NWSIndexPath.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSPath.h"

/**
 * A path to access indexed elements.
 *
 * @see NWSPath
 */
@interface NWSIndexPath : NWSPath

/**
 * Any index between `-count` and `count - 1`, where a negative index wraps once.
 */
@property (nonatomic, assign) NSInteger index;

- (id)initWithIndex:(NSInteger)index;

/**
 * Parses an index string. The string should be an integer number.
 * @param string A index string.
 */
+ (NWSIndexPath *)pathFromString:(NSString *)string;

@end
