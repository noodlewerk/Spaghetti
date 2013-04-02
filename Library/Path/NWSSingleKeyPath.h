//
//  NWSSingleKeyPath.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSPath.h"

/**
 * Path to a direct property, basically a single-element key path.
 *
 * @see NWSPath
 */
@interface NWSSingleKeyPath : NWSPath

/**
 * Name of a property (attribute or relation), used in calls to `valueForKey:` and `setValue:forKey:`.
 */
@property (nonatomic, copy) NSString *key;

- (id)initWithKey:(NSString *)key;

@end
