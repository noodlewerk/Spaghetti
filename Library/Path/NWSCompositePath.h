//
//  NWSCompositePath.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
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

@end
