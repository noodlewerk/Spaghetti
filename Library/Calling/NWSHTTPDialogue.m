//
//  NWSHTTPDialogue.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSHTTPDialogue.h"
#import "NWSHTTPConnection.h"
#import "NWSHTTPCall.h"
#import "NWSHTTPEndpoint.h"
#import "NWSVarStat.h"
#import "NWSMapping.h"


@implementation NWSHTTPDialogue {
    NSDate *startCall;
    NSDate *startRequest;
    NWSHTTPConnection *connection;
    BOOL cancelled;
}

@synthesize request, response, data;


#pragma mark - Vallbacks

- (void)doneWithResult:(id)result
{
    void(^callbackBlock)() = ^{        
        // check cancel
        if (cancelled) {
            NWLogInfo(@"cancelled");
            return;
        }
        if (self.call.doneBlock) self.call.doneBlock(result);
        if (result) {
            NWLogInfo(@"done call (total:%.3fs)", DEBUG_STAT_INTERVAL_IN(startCall));
            DEBUG_STAT_STOP_IN(startCall, self.call.endpoint.totalTime);
        } else {
            NWLogInfo(@"failed call");
        }
    };
    [self.callbackQueue addOperationWithBlock:callbackBlock];
}

#pragma mark - Dialogue process

- (void)map
{
    NWLogWarnIfNot(NSOperationQueue.currentQueue == self.operationQueue, @"Expecting to run on queue: %@", self.operationQueue);
    // check cancel
    if (cancelled) {
        NWLogInfo(@"cancelled");
        return;
    }
    
    id result = [self mapData:data useTransactionStore:YES];
    [self doneWithResult:result];
}

- (void)connect
{
    // send request
    NWLogInfo(@"sending request (expected:%.3fs)", self.call.endpoint.requestTime.average);
    DEBUG_STAT_START_IN(startRequest);
    
    NWSConnectionDoneBlock doneBlock = ^(NSHTTPURLResponse *_response, NSData *_data) {
        connection = nil;
        DEBUG_STAT_STOP_IN(startRequest, self.call.endpoint.requestTime);
        // check cancel
        if (cancelled) {
            NWLogInfo(@"cancelled");
            return;
        }
        // keep response
        response = (NSHTTPURLResponse *)_response;
        data = _data;
        if (!data) {
            NWLogWarn(@"response data is nil");
            [self doneWithResult:nil];
            return;
        }
        [self map];
    };
    
    NWLogWarnIfNot(!connection, @"Dialogue should not run twice");
    connection = [[NWSHTTPConnection alloc] initWithRequest:request];
    connection.doneBlock = doneBlock;
    connection.callbackQueue = self.operationQueue;
    connection.indicator = self.indicator;
    [connection start];
}

- (void)compose
{
    NWLogWarnIfNot(NSOperationQueue.currentQueue == self.operationQueue, @"Expecting to run on queue: %@", self.operationQueue);
    
    NWSHTTPCall *httpCall = (NWSHTTPCall *)self.call;
    
    // compose http request
    NSURL *u = httpCall.resolvedURL;
    NSMutableURLRequest *r = [[NSMutableURLRequest alloc] initWithURL:u];
    for (NSString *key in httpCall.headers) {
        NSString *v = [httpCall.headers objectForKey:key];
        NSString *value = [NWSCall dereference:v parameters:self.call.parameters];
        [r setValue:value forHTTPHeaderField:key];
    }
    if (httpCall.method) {
        r.HTTPMethod = httpCall.method;
    }
    
    // TODO: remove!
    //    r.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    // compose body
    NSObject *bodyObject = self.call.requestObject;
    if (bodyObject) {
        NSData *bodyData = [self mapObject:bodyObject];
        r.HTTPBody = bodyData;
    }
    
    request = r;
    [self connect];
}

- (void)start
{
    DEBUG_STAT_START_IN(startCall);
    
    NWLogWarnIfNot(self.call.store, @"Expecting a store to map to on dialogue start");
    
    NWLogInfo(@"start call (expected:%.3fs)", self.call.endpoint.totalTime.average);
    // check cancel
    if (cancelled) {
        NWLogInfo(@"cancelled");
        return;
    }
    
    if (!self.callbackQueue) {
        self.callbackQueue = NSOperationQueue.currentQueue;
        NWLogWarnIfNot(self.callbackQueue, @"No callback queue set or available, set manually");
    }
    
    NWLogWarnIfNot(self.operationQueue, @"Wouldn't it be better if you gave me the queue?");
    
    if (!self.operationQueue) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    
    NWLogWarnIfNot(self.operationQueue.maxConcurrentOperationCount == 1, @"Concurrent mapping not allowed.");
    
    void(^requestBlock)() = ^{
        [self compose];
    };
    [self.operationQueue addOperationWithBlock:requestBlock];
}

- (void)cancel
{
    cancelled = YES;
    [connection cancel]; connection = nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@>", NSStringFromClass(self.class), self, request.URL];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"dialogue with %@", request.URL] readable:prefix];
}

@end
