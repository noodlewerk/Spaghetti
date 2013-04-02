//
//  NWSHTTPDialogue.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSDialogue.h"

@class NWSHTTPCall;

/**
 * An NWSDialogue over HTTP, a single call to a server.
 *
 * @see NWSDialogue
 */
@interface NWSHTTPDialogue : NWSDialogue

/**
 * The request to be run.
 */
@property (nonatomic, strong, readonly) NSURLRequest *request;

/**
 * The response, if one has been received.
 */
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;

/**
 * The response data, if any data was received.
 */
@property (nonatomic, strong, readonly) NSData *data;

@end
