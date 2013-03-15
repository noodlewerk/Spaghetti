//
//  NWSHTTPConnection.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSHTTPConnection.h"
#import "NWSActivityIndicator.h"


@implementation NWSHTTPConnection {
    NSURLRequest *_request;
    NSURLConnection *_connection;
    NSHTTPURLResponse *_response;
    NSMutableData *_responseData;
}


#pragma mark - Object life cycle

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}

#pragma mark - Connection

- (void)start
{
    NWLogWarnIfNot(!_connection, @"A started connection cannot be restarted");
    NWLogWarnIfNot(_request, @"Cannot start a connection without request");
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:NSRunLoop.mainRunLoop forMode:NSDefaultRunLoopMode];
    if (_connection) {
        if (!_callbackQueue) {
            _callbackQueue = NSOperationQueue.currentQueue;
        }
        [_connection start];
        NWLogInfo(@"Registering call: %@", _request.URL);
        [_indicator registerActivity];
    } else {
        NWLogWarn(@"Failed to init NSURLConnection");
        if (_block) _block(nil, nil); _block = nil;
    }
}

- (void)cancel
{
    [_connection cancel]; _connection = nil;
    NWLogInfo(@"Unregistering call: %@", _request.URL);
    [_indicator unregisterActivity];
    _block = nil;
}


#pragma mark - URL Connection Delegate

#ifdef DEBUG
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
} 
#endif

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NWLogWarnIfNot(!_response, @"Receiving a response twice");
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_responseData) {
        _responseData = [NSMutableData dataWithData:data];
    } else {
        [_responseData appendData:data];
    }
}

//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _connection = nil;
    NWLogInfo(@"Unregistering call: %@", _request.URL);
    [_indicator unregisterActivity];
    if (_block) {
        void(^b)(NSHTTPURLResponse *response, NSData *data) = _block;
        void(^block)() = ^{b(_response, _responseData);};
        [_callbackQueue addOperationWithBlock:block];
    }
    // break retain cycles
    _block = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NWLogWarnIfError(error);
    _connection = nil;
    NWLogInfo(@"Unregistering call: %@", _request.URL);
    [_indicator unregisterActivity];
    if (_block) {
        void(^b)(NSHTTPURLResponse *response, NSData *data) = _block;
        void(^block)() = ^{b(_response, _responseData);};
        [_callbackQueue addOperationWithBlock:block];
    }
    // break retain cycles
    _block = nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@>", NSStringFromClass(self.class), self, _request.URL];
}

- (NSString *)about:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"connection to %@ (%u,%u)", _request.URL, (int)_response.statusCode, (int)_responseData.length] about:prefix];
}

@end
