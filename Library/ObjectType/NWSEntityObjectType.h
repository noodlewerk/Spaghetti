//
//  NWSEntityObjectType.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NWSObjectType.h"

/**
 * The class object type wraps NSEntityDescription.
 *
 * This type is mainly used by the core data store, allowing object fetches and inserts.
 *
 * @see NWSObjectType
 * @see NWSCoreDataStore
 */
@interface NWSEntityObjectType : NWSObjectType

@property (nonatomic, strong) NSEntityDescription *entity;

- (id)initWithEntity:(NSEntityDescription *)entity;

@end
