//
//  NWSDialogue.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@class NWSCall;
@protocol NWSActivityIndicator;

/**
 * A actual conversation based on a call, should be disposed after use.
 *
 * Please refer to NWSEndpoint for an explanation how NWSDialogue relates to NWSEndpoint and NWSCall.
 */
@interface NWSDialogue : NSObject

/**
 * The call that is the prototype for this dialogue. Required.
 */
@property (nonatomic, strong) NWSCall *call;

/**
 * The queue on which all time-consuming operations should be scheduled. If none is provided, an new operation queue will be created.
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

/**
 * The queue on which the dialogue should report success or failure. If none is provided, the same queue as the one start was invoked on will be used.
 * @see [NWSCall doneBlock]
 */
@property (nonatomic, strong) NSOperationQueue *callbackQueue;

/**
 * An indicator this dialogue will register on as long as it's running.
 * @see [NWSCall indicator]
 * @see NWSActivityIndicator
 */
@property (nonatomic, strong) id<NWSActivityIndicator> indicator;

- (id)initWithCall:(NWSCall *)call;

/**
 * Starts the dialogue, returns immediately.
 */
- (void)start;

/**
 * Flags the dialogue to be cancelled asap. Callbacks will not be fired.
 */
- (void)cancel;

- (id)mapData:(NSData *)data useTransactionStore:(BOOL)useStore;
- (NSData *)mapObject:(NSObject *)object;

@end
