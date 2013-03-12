//
//  NWSHTTPEndpoint.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSHTTPEndpoint.h"
#import "NWSCommon.h"
#import "NWSHTTPCall.h"
#import "NWSSelfPath.h"


@implementation NWSHTTPEndpoint {
    NSMutableDictionary *_headers;
}


#pragma mark - Object life cycle

- (id)newCall
{
    return [[NWSHTTPCall alloc] initWithEndpoint:self];
}

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key
{
    if (!_headers) {
        _headers = [[NSMutableDictionary alloc] init];
    } else if (![_headers isKindOfClass:NSMutableDictionary.class]) {
        _headers = [[NSMutableDictionary alloc] initWithDictionary:_headers];
    }
    [_headers setObject:value forKey:key];
}

- (id)copyWithZone:(NSZone *)zone
{
    NWSHTTPEndpoint *result = [super copyWithZone:zone];
    result.urlString = _urlString;
    result.headers = _headers;
    result.method = _method;
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@ req-map:%@ res-map:%@ store:%@>", NSStringFromClass(self.class), self, _urlString, self.requestMapping, self.responseMapping, self.store];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"http-endpoint on %@", _urlString] readable:prefix];
}

@end

