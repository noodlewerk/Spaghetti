//
//  NWSCompositePath.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSPath.h"

/**
 * A path that consists of a sequence of paths.
 *
 * Properties are accessed by sequentially applying its paths, allowing different kinds of paths to be used as one.
 *
 * @see NWSPath
 */
@interface NWSCompositePath : NWSPath

/**
 * An array of NWSPath objects.
 */
@property (nonatomic, strong) NSArray *paths;

- (id)initWithPaths:(NSArray *)paths;

/**
 * Generates a composite path by splitting the provided string and converting each component to a path. Components are separated by ':' (colon). Conversion is done using [NWSPath pathFromString:] for each component.
 * @param string A string with path components separated by ':'.
 * @see [NWSPath pathFromString:]
 */
+ (NWSCompositePath *)pathFromString:(NSString *)string;

@end
