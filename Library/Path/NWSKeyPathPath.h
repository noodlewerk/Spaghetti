//
//  NWSKeyPathPath.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSPath.h"

/**
 * Path based on a KVC key path.
 *
 * @see NWSPath
 */
@interface NWSKeyPathPath : NWSPath

/**
 * A key path that will be used in calls to `valueForKeyPath:` and `setValue:forKeyPath:`.
 */
@property (nonatomic, copy) NSString *keyPath;

- (id)initWithKeyPath:(NSString *)keyPath;

@end
