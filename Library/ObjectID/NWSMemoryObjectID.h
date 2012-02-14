//
//  NWSMemoryObjectID.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSObjectID.h"

/**
 * One of the more basic object ids, simply identifying the object by its memory address.
 *
 * The memory object id is mostly used by the NWSBasicStore, which simply holds objects in memory.
 *
 * @see NWSObjectID
 */
@interface NWSMemoryObjectID : NWSObjectID

@property (nonatomic, strong, readonly) NSObject *object;

- (id)initWithObject:(NSObject *)object;

@end
