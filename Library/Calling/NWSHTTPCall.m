//
//  NWSHTTPCall.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSHTTPCall.h"
#import "NWSHTTPDialogue.h"
#import "NWSHTTPEndpoint.h"


@implementation NWSHTTPCall {
    NSMutableDictionary *_headers;
}

- (id)initWithEndpoint:(NWSHTTPEndpoint *)endpoint
{
    self = [super initWithEndpoint:endpoint];
    if (self) {
        _urlString = [endpoint.urlString copy];
        _headers = [[NSMutableDictionary alloc] initWithDictionary:endpoint.headers];
        _method = [endpoint.method copy];
    }
    return self;
}

- (id)newDialogue
{
    return [[NWSHTTPDialogue alloc] initWithCall:self];
}

- (id)copyWithZone:(NSZone *)zone
{
    NWSHTTPCall *result = [super copyWithZone:zone];
    result.urlString = _urlString;
    result.headers = [_headers mutableCopy];
    result.method = _method;
    return result;
}


#pragma mark - Accessors

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key
{
    if (!_headers) {
        _headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:value, key, nil];
    } else {
        _headers[key] = value;
    }
}

- (void)setHeaders:(NSDictionary *)headers
{
    if (!_headers) {
        _headers = [[NSMutableDictionary alloc] initWithDictionary:headers];
    } else {
        [_headers addEntriesFromDictionary:headers];
    }
}

- (NSURL *)resolvedURL
{
    NSString *dereffed = [NWSCall dereference:_urlString parameters:self.parameters];
    NSURL *result = [[NSURL alloc] initWithString:dereffed]; 
    return result;
}

- (NSString *)name
{
    NSString *result = [NWSCall dereference:_urlString parameters:self.parameters];
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@ req-map:%@ res-map:%@ store:%@>", NSStringFromClass(self.class), self, _urlString, self.requestMapping, self.responseMapping, self.store];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"http-call to %@", self.name] readable:prefix];
}

@end
