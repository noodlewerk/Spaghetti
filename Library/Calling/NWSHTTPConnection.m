//
//  NWSHTTPConnection.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSHTTPConnection.h"
#import "NWSActivityIndicator.h"


@implementation NWSHTTPConnection {
    NSURLRequest *request;
    NSURLConnection *connection;
    NSHTTPURLResponse *response;
    NSMutableData *responseData;
}

@synthesize doneBlock, callbackQueue, indicator;


#pragma mark - Object life cycle

- (id)initWithRequest:(NSURLRequest *)_request
{
    self = [super init];
    if (self) {
        request = _request;
    }
    return self;
}

#pragma mark - Connection

- (void)start
{
    NWLogWarnIfNot(!connection, @"A started connection cannot be restarted");
    NWLogWarnIfNot(request, @"Cannot start a connection without request");
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:NSRunLoop.mainRunLoop forMode:NSDefaultRunLoopMode];
    if (connection) {
        if (!callbackQueue) {
            callbackQueue = NSOperationQueue.currentQueue;
        }
        [connection start];
        NWLogInfo(@"Registering call: %@", request.URL);
        [indicator registerActivity];
    } else {
        NWLogWarn(@"Failed to init NSURLConnection");
        if (doneBlock) doneBlock(nil, nil);
    }
}

- (void)cancel
{
    [connection cancel]; connection = nil;
    NWLogInfo(@"Unregistering call: %@", request.URL);
    [indicator unregisterActivity];
    doneBlock = nil;
}


#pragma mark - URL Connection Delegate

#ifdef DEBUG
- (BOOL)connection:(NSURLConnection *)_connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)_connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
} 
#endif

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)_request redirectResponse:(NSURLResponse *)_response

- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSHTTPURLResponse *)_response
{
    NWLogWarnIfNot(!response, @"Receiving a response twice");
    response = _response;
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)data
{
    if (!responseData) {
        responseData = [NSMutableData dataWithData:data];
    } else {
        [responseData appendData:data];
    }
}

//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
    connection = nil;
    NWLogInfo(@"Unregistering call: %@", request.URL);
    [indicator unregisterActivity];
    if (doneBlock) {
        NWSConnectionDoneBlock b = doneBlock;
        void(^block)() = ^{b(response, responseData);};
        [callbackQueue addOperationWithBlock:block];
    }
    // break retain cycles
    doneBlock = nil;
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error
{
    NWLogWarnIfError(error);
    connection = nil;
    NWLogInfo(@"Unregistering call: %@", request.URL);
    [indicator unregisterActivity];
    if (doneBlock) {
        NWSConnectionDoneBlock b = doneBlock;
        void(^block)() = ^{b(response, responseData);};
        [callbackQueue addOperationWithBlock:block];
    }
    // break retain cycles
    doneBlock = nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@>", NSStringFromClass(self.class), self, request.URL];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"connection to %@ (%u,%u)", request.URL, (int)response.statusCode, (int)responseData.length] readable:prefix];
}

@end
