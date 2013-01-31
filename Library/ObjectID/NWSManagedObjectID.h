//
//  NWSManagedObjectID.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSObjectID.h"
#import <CoreData/CoreData.h>
/**
 * The object id used by the NWSCoreDataStore, wraps NWSManagedObjectID.
 *
 * @see NWSObjectID
 */
@interface NWSManagedObjectID : NWSObjectID

@property (nonatomic, strong) NSManagedObjectID *ID;

- (id)initWithID:(NSManagedObjectID *)ID;

@end
