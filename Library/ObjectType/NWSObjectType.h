//
//  NWSObjectType.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@class NWSPath;

/**
 * An object type represents the kind (type, class, entity) of an object, similar to the Class 'object'.
 *
 * The object type is used by NWSStore to indicate which type of object needs to be fetched or instantiated.
 *
 * @see NWSStore
 */
@interface NWSObjectType : NSObject

/**
 * Returns YES if the object is of this type.
 * @param object The subject of the test.
 */
- (BOOL)matches:(NSObject *)object;
+ (BOOL)supports:(NSObject *)object;

/**
 * Returns YES if instances of this type have a certain attribute.
 * @param attribute The path of the attribute.
 */
- (BOOL)hasAttribute:(NWSPath *)attribute;

/**
 * Returns YES if instances of this type have a certain relation.
 * @param relation The path of the relation.
 * @param toMany The to-many-ness of the relation.
 */
- (BOOL)hasRelation:(NWSPath *)relation toMany:(BOOL)toMany;

@end
