//
//  NWSHTTPConnection.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

typedef void(^NWSConnectionDoneBlock)(NSHTTPURLResponse *response, NSData *data);

@protocol NWSActivityIndicator;

/**
 * A convenience wrapper around NSURLConnection.
 *
 * Similar to the sendAsynchronousRequest: method of NSURLConnection, but also provides a cancel method.
 */
@interface NWSHTTPConnection : NSObject<NSURLConnectionDelegate>

/**
 * The callback block that is invoked as soon as the NSURLConnection finishes or fails.
 */
@property (nonatomic, copy) NWSConnectionDoneBlock doneBlock;

/**
 * The queue on which the doneBlock will be invoked.
 */
@property (nonatomic, strong) NSOperationQueue *callbackQueue;

/**
 * Indicator this connection will register on after starting.
 */
@property (nonatomic, strong) id<NWSActivityIndicator> indicator;

/**
 * Initialize with request.
 * @param request The request fed to a NSURLConnection.
 */
- (id)initWithRequest:(NSURLRequest *)request;

/**
 * Kicks off the NSURLConnection on the main runloop.
 */
- (void)start;

/**
 * Cancels any running connection without calling the doneBlock.
 */
- (void)cancel;

@end
