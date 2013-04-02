//
//  NWSPolicy.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kNWSPolicyReplace = 0,
    kNWSPolicyAppend = 1,
    kNWSPolicyDelete = 2
} NWSPolicyType;

/**
 * Defines how a relation should be set in terms of which of the original values remain and which of the new values are added.
 */
@interface NWSPolicy : NSObject

/**
 * The policy type that is wrapped by this object.
 */
@property (nonatomic, readonly) NWSPolicyType type;

/**
 * The to-many-ness of the relation.
 */
@property (nonatomic, readonly) BOOL toMany;

/**
 * Policy that disconnects the current relation object and sets the new object.
 */
+ (NWSPolicy *)replaceOne;

/**
 * Policy that disconnects the current relation objects and sets the new objects.
 */
+ (NWSPolicy *)replaceMany;

/**
 * Policy that adds the new objects to the existing relations.
 */
+ (NWSPolicy *)appendMany;

/**
 * Policy that deletes the current relation object and sets the new object.
 */
+ (NWSPolicy *)deleteOne;

/**
 * Policy that deletes the current relation objects and sets the new objects.
 */
+ (NWSPolicy *)deleteMany;

@end
