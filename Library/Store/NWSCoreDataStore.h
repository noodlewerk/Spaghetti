//
//  NWSCoreDataStore.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NWSStore.h"

typedef enum {
    kNWSTransactionTypeNewContext = 0,
    kNWSTransactionTypeCurrentContext = 1,
    // kNWSTransactionTypeChildContext = 2,
} NWSTransactionType;


/**
 * A store based on a NSManagedObjectContext.
 *
 * The Core Data store provides the mapping process access to a managed object context though the reduced interface of NWSStore. With this context should come an operation queue that will be used to perform am-i-on-the-right-thread checks.
 *
 * @see NWSStore
 * @see NWSBasicStore
 * @see NWSMapping
 */
@interface NWSCoreDataStore : NWSStore

/**
 * The managed object context this store is all about.
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

/**
 * The queue on which all context-related messages should be sent.
 */
@property (nonatomic, strong, readonly) NSOperationQueue *queue;

@property (nonatomic, assign) NWSTransactionType transactionType;

/**
 * Initialize this store with its NSManagedObjectContext.
 * @param context The managed object context this store is all about.
 * @param queue The queue on which all context-related messages should be sent.
 */
- (id)initWithContext:(NSManagedObjectContext *)context queue:(NSOperationQueue *)queue;

@end
