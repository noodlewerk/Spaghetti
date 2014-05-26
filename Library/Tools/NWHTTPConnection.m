//
//  NWHTTPConnection.m
//  NWTools
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWHTTPConnection.h"
#import "NWActivityIndicator.h"
//#include "NWSLCore.h"


@interface NWHTTPConnection ()
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableData *responseData;
@end


@implementation NWHTTPConnection {
    NSURLConnection *_connection;
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
    NWSLogWarnIfNot(!_connection, @"A started connection cannot be restarted");
    NWSLogWarnIfNot(_request, @"Cannot start a connection without request");
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:NSRunLoop.mainRunLoop forMode:NSDefaultRunLoopMode];
    if (_connection) {
        if (!_callbackQueue) {
            NWAssertMainThread();
            _callbackQueue = NSOperationQueue.mainQueue;
        }
        NWSLogDbug(@"Starting call: %@", _request.URL);
        [_connection start];
        [_indicator registerActivity];
    } else {
        NWSLogWarn(@"Failed to init NSURLConnection");
        void(^b)(NSHTTPURLResponse *response, NSData *data) = _block; _block = nil;
        if (b) [_callbackQueue addOperationWithBlock:^{b(nil, nil);}];
    }
}

- (void)cancel
{
    if (_connection) {
        NWSLogInfo(@"Cancelled call: %@", _request.URL);
        [_connection cancel]; _connection = nil;
        [_indicator unregisterActivity];
    }
    void(^b)(NSHTTPURLResponse *response, NSData *data) = _block; _block = nil;
    if (b) [_callbackQueue addOperationWithBlock:^{b(nil, nil);}];
}

- (void)finished
{
    NWSLogDbug(@"Finished call: %@", _request.URL);
    _connection = nil;
    [_indicator unregisterActivity];
    void(^b)(NSHTTPURLResponse *response, NSData *data) = _block; _block = nil;
    if (b) [_callbackQueue addOperationWithBlock:^{b(_response, _responseData);}];
}


#pragma mark - URL Connection Delegate

#if TARGET_IPHONE_SIMULATOR
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}
#endif

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NWSLogWarnIfNot(!_response, @"Receiving a response twice");
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self finished];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NWSLogWarnIfError(error);
    [self cancel];
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@>", NSStringFromClass(self.class), (__bridge void *)self, _request.URL];
}

@end
