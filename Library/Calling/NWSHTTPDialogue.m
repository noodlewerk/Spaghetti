//
//  NWSHTTPDialogue.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSHTTPDialogue.h"
#import "NWHTTPConnection.h"
#import "NWSHTTPCall.h"
#import "NWSHTTPEndpoint.h"
#import "NWStats.h"
#import "NWSMapping.h"
#import "NWAbout.h"
//#include "NWSLCore.h"


@implementation NWSHTTPDialogue {
    NSDate *_startCall;
    NSDate *_startRequest;
    NWHTTPConnection *_connection;
    BOOL _cancelled;
}

#pragma mark - Vallbacks

- (void)doneWithResult:(id)result
{
    void(^callbackBlock)() = ^{        
        // check cancel
        if (_cancelled) {
            NWSLogSpag(@"cancelled");
            return;
        }
        [self.call doneWithResult:result];
        if (result) {
            NWSLogSpag(@"done call (total:%.3fs)", DEBUG_STAT_INTERVAL_IN(_startCall));
            DEBUG_STAT_STOP_IN(_startCall, self.call.endpoint.totalTime);
        } else {
            NWSLogSpag(@"failed call");
        }
    };
    [self.callbackQueue addOperationWithBlock:callbackBlock];
}

#pragma mark - Dialogue process

- (void)map
{
    NWSLogWarnIfNot(NSOperationQueue.currentQueue == self.operationQueue, @"Expecting to run on queue: %@", self.operationQueue);
    // check cancel
    if (_cancelled) {
        NWSLogSpag(@"cancelled");
        return;
    }
    
    id result = [self mapData:_data useTransactionStore:YES];
    [self doneWithResult:result];
}

- (void)connect
{
    // send request
    NWSLogSpag(@"sending request (expected:%.3fs)", self.call.endpoint.requestTime.average);
    DEBUG_STAT_START_IN(_startRequest);
    
    void(^block)(NSHTTPURLResponse *response, NSData *data) = ^(NSHTTPURLResponse *response, NSData *data) {
        _connection = nil;
        DEBUG_STAT_STOP_IN(_startRequest, self.call.endpoint.requestTime);
        // check cancel
        if (_cancelled) {
            NWSLogSpag(@"cancelled");
            return;
        }
        // keep response
        _response = (NSHTTPURLResponse *)response;
        _data = data;
        if (!_data) {
            NWSLogWarn(@"response data is nil");
            [self doneWithResult:nil];
            return;
        }
        [self map];
    };
    
    NWHTTPConnection *connection = [[NWHTTPConnection alloc] initWithRequest:_request];
    connection.block = block;
    connection.callbackQueue = self.operationQueue;
    connection.indicator = self.indicator;
    [connection start];
    NWSLogWarnIfNot(!_connection, @"Dialogue should not run twice");
    _connection = connection;
}

- (NSURLRequest *)composeRequest
{
    NWSLogWarnIfNot(NSOperationQueue.currentQueue == self.operationQueue, @"Expecting to run on queue: %@", self.operationQueue);
    
    NWSHTTPCall *httpCall = (NWSHTTPCall *)self.call;
    
    // compose http request
    NSURL *u = httpCall.resolvedURL;
    if (u) {
        NSMutableURLRequest *result = [[NSMutableURLRequest alloc] initWithURL:u];
        for (NSString *key in httpCall.headers) {
            NSString *v = (httpCall.headers)[key];
            NSString *value = [NWSCall dereference:v parameters:self.call.parameters];
            [result setValue:value forHTTPHeaderField:key];
        }
        if (httpCall.method) {
            result.HTTPMethod = httpCall.method;
        }
        
        // TODO: remove!
        //    r.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        // compose body
        NSObject *bodyObject = self.call.requestObject;
        if (bodyObject) {
            NSData *bodyData = [self mapObject:bodyObject];
            result.HTTPBody = bodyData;
        }
        
        return result;
    } else {
        NWSLogWarn(@"Expecting valid url: %@", httpCall.urlString);
    }
    return nil;
}

- (void)start
{
    DEBUG_STAT_START_IN(_startCall);
        
    NWSLogSpag(@"start call (expected:%.3fs)", self.call.endpoint.totalTime.average);
    // check cancel
    if (_cancelled) {
        NWSLogSpag(@"cancelled");
        return;
    }
    
    if (!self.callbackQueue) {
        self.callbackQueue = NSOperationQueue.currentQueue;
        NWSLogWarnIfNot(self.callbackQueue, @"No callback queue set or available, set manually");
    }
        
    if (!self.operationQueue) {
        static NSOperationQueue *fallbackQueue = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            fallbackQueue = [[NSOperationQueue alloc] init];
            fallbackQueue.maxConcurrentOperationCount = 1;
        });
        self.operationQueue = fallbackQueue;
    }
    
    NWSLogWarnIfNot(self.operationQueue.maxConcurrentOperationCount == 1, @"Concurrent mapping not allowed.");
    
    void(^requestBlock)() = ^{
        NSURLRequest *r = [self composeRequest];
        if (r) {
            _request = r;
            [self connect];
        } else {
            NWSLogWarn(@"Unable to compse request, call cancelled");
        }
    };
    [self.operationQueue addOperationWithBlock:requestBlock];
}

- (void)cancel
{
    _cancelled = YES;
    [_connection cancel]; _connection = nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@>", NSStringFromClass(self.class), self, _request.URL];
}

- (NSString *)about:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"dialogue with %@", _request.URL] about:prefix];
}

@end
