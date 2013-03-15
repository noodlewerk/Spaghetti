//
//  NWHTTPConnection.h
//  NWTools
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NWActivityIndicator;

/**
 * A convenience wrapper around NSURLConnection.
 *
 * Similar to the sendAsynchronousRequest: method of NSURLConnection, but also provides a cancel method.
 */
@interface NWHTTPConnection : NSObject<NSURLConnectionDelegate>

/**
 * The callback block that is invoked as soon as the NSURLConnection finishes or fails.
 */
@property (nonatomic, copy) void(^block)(NSHTTPURLResponse *response, NSData *data);

/**
 * The queue on which the completion block will be invoked.
 */
@property (nonatomic, strong) NSOperationQueue *callbackQueue;

/**
 * Indicator this connection will register on after starting.
 */
@property (nonatomic, strong) id<NWActivityIndicator> indicator;

@property (nonatomic, strong) NSURLRequest *request;

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
 * Cancels any running connection without calling the completion block.
 */
- (void)cancel;

@end
