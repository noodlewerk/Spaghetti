//
//  NWSHTTPCall.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSHTTPCall.h"
#import "NWSHTTPDialogue.h"
#import "NWSHTTPEndpoint.h"


@implementation NWSHTTPCall {
    NSMutableDictionary *headers;
}

@synthesize urlString, headers, method;

- (id)initWithEndpoint:(NWSHTTPEndpoint *)_endpoint
{
    self = [super initWithEndpoint:_endpoint];
    if (self) {
        urlString = [_endpoint.urlString copy];
        headers = [[NSMutableDictionary alloc] initWithDictionary:_endpoint.headers];
        method = [_endpoint.method copy];
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
    result.urlString = urlString;
    result.headers = [headers mutableCopy];
    result.method = method;
    return result;
}


#pragma mark - Accessors

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key
{
    if (!headers) {
        headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:value, key, nil];
    } else {
        [headers setObject:value forKey:key];
    }
}

- (void)setHeaders:(NSDictionary *)_headers
{
    if (!headers) {
        headers = [[NSMutableDictionary alloc] initWithDictionary:_headers];
    } else {
        [headers addEntriesFromDictionary:_headers];
    }
}

- (NSURL *)resolvedURL
{
    NSString *dereffed = [NWSCall dereference:urlString parameters:self.parameters];
    NSURL *result = [[NSURL alloc] initWithString:dereffed]; 
    NWLogWarnIfNot(result, @"Malformed URL string: %@", dereffed);
    return result;
}

- (NSString *)name
{
    return self.resolvedURL.absoluteString;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@ req-map:%@ res-map:%@ store:%@>", NSStringFromClass(self.class), self, urlString, self.requestMapping, self.responseMapping, self.store];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"http-call to %@", self.name] readable:prefix];
}

@end
