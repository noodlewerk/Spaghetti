//
//  NWSIDToObjectTransform.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"


@class NWSObjectType, NWSPath;

/**
 * Transforms a primary value to an object by fetching the object with that value for a given primary key.
 * 
 * This transform is used for mapping an object reference by id to a relation on an actual object. For example `{"id":2,"parent_id":1}` is mapped to object X with `X.id = 2` and `X.parent = Y`, where `Y.id = 1`.
 *
 * @see NWSObjectType
 * @see NWSTransform
 */
@interface NWSIDToObjectTransform : NWSTransform

/**
 * The type of the object that is output by this transform.
 */
@property (nonatomic, strong) NWSObjectType *type;

/**
 * The path (primary key) in the object that should have a matching value.
 */
@property (nonatomic, strong) NWSPath *path;

/**
 * Indicates whether a new object should be create if no existing object matches the value for the given path.
 */
@property (nonatomic, assign) BOOL create;

/**
 * Init with create = YES by default.
 * @param type The type of the object that is output by this transform.
 * @param path The path (primary key) of the object we're matching.
 */
- (id)initWithType:(NWSObjectType *)type path:(NWSPath *)path;

@end
