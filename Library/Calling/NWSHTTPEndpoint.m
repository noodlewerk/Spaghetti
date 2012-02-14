//
//  NWSHTTPEndpoint.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSHTTPEndpoint.h"
#import "NWSCommon.h"
#import "NWSHTTPCall.h"
#import "NWSSelfPath.h"


@implementation NWSHTTPEndpoint {
    NSMutableDictionary *headers;
}

@synthesize urlString, headers, method;


#pragma mark - Object life cycle

- (id)newCall
{
    return [[NWSHTTPCall alloc] initWithEndpoint:self];
}

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key
{
    if (!headers) {
        headers = [[NSMutableDictionary alloc] init];
    } else if (![headers isKindOfClass:NSMutableDictionary.class]) {
        headers = [[NSMutableDictionary alloc] initWithDictionary:headers];
    }
    [headers setObject:value forKey:key];
}

- (id)copyWithZone:(NSZone *)zone
{
    NWSHTTPEndpoint *result = [super copyWithZone:zone];
    result.urlString = urlString;
    result.headers = headers;
    result.method = method;
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p url:%@ req-map:%@ res-map:%@ store:%@>", NSStringFromClass(self.class), self, urlString, self.requestMapping, self.responseMapping, self.store];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"http-endpoint on %@", urlString] readable:prefix];
}

@end

