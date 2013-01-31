//
//  NWSSelfPath.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSPath.h"

/**
 * Path that returns the object that it is applied to.
 *
 * Note that a self-path can only be used for getting, i.e. valueWithObject:. Setting to a self-path is conceptually undefined and will be ignored.
 *
 * @see NWSPath
 */
@interface NWSSelfPath : NWSPath

/**
 * Since all paths to self are identical, this is the preferred way of getting an instance.
 */
+ (NWSSelfPath *)shared;

@end
