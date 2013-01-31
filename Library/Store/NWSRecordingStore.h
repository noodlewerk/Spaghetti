//
//  NWSRecordingStore.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSStore.h"


@interface NWSAttributeRecord : NSObject
@property (nonatomic, strong) NWSObjectID *identifier;
@property (nonatomic, strong) NWSPath *path;
@property (nonatomic, strong) id value;
@end


@interface NWSRelationRecord : NSObject
@property (nonatomic, strong) NWSObjectID *identifier;
@property (nonatomic, strong) NWSPath *path;
@property (nonatomic, strong) NWSObjectID *value;
@property (nonatomic, strong) NWSPolicy *policy;
@end


/**
 * Records all operations performed, so they can be replayed at a later time on another store.
 */
@interface NWSRecordingStore : NWSStore

/**
 * The collection of records that have been gathered in calls to this class.
 */
@property (nonatomic, strong, readonly) NSMutableArray *records;

/**
 * Apply and clear all records by forwarding the recorded calls to the given store.
 * @param store The receiving store.
 */
- (void)applyToStore:(NWSStore *)store;

@end
