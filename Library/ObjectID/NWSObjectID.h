//
//  NWSObjectID.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * An object id is an identifier for a specific object, but without any need for a reference to the object or for the object to exist at all.
 *
 * It's use is similar to that of an NSManagedObjectID and allows NWSMapping and NWSStore to refer to objects in a generic way. Most object ids are tied to a specific store, identifying an object in that store.
 *
 * @see NWSStore
 */
@interface NWSObjectID : NSObject

@end
