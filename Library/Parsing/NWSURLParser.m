//
//  NWSURLParser.m
//  NWService
//
//  Created by leonard on 7/18/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSURLParser.h"

@implementation NWSURLParser

+ (NSString *)escapeForURL:(NSString *)s
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)s, NULL, CFSTR("*'();:@&=+$,/?!%#[]"), kCFStringEncodingUTF8);
}

+ (NSString *)unescapeForURL:(NSString *)s
{
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)s, CFSTR(""), kCFStringEncodingUTF8);
}

- (NSDictionary *)parse:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *components = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:components.count];
    for (NSString *pair in components) {
        NSRange r = [pair rangeOfString:@"="];
        NSString *key = nil;
        id value = nil;
        if (r.length) {
            key = [self.class unescapeForURL:[pair substringToIndex:r.location]];
            value = [self.class unescapeForURL:[pair substringFromIndex:r.location + r.length]];
        } else {
            key = [self.class unescapeForURL:pair];
            value = NSNull.null;
        }
        [result setObject:value forKey:key];
    }
    return result;
}

- (NSData *)serialize:(NSDictionary *)dictionary
{
    NSMutableString *s = [[NSMutableString alloc] init];
    for (NSString *key in dictionary) {
        id value = [dictionary objectForKey:key];
        NSString *k = [self.class escapeForURL:key.description];
        if ([value isKindOfClass:NSArray.class]) {
            for (NSString *val in value) {
                if ([val isKindOfClass:NSNull.class]) {
                    [s appendFormat:@"%@%@[]", s.length ? @"&" : @"", k];
                } else {
                    NSString *v = [self.class escapeForURL:val.description];
                    [s appendFormat:@"%@%@[]=%@", s.length ? @"&" : @"", k, v];
                }
            }
        } else if ([value isKindOfClass:NSNull.class]) {
            [s appendFormat:@"%@%@", s.length ? @"&" : @"", k];           
        } else {
            NSString *v = [self.class escapeForURL:[value description]];
            [s appendFormat:@"%@%@=%@", s.length ? @"&" : @"", k, v];
        }
    }
    NSData *result = [s dataUsingEncoding:NSUTF8StringEncoding];
    return result;
}

+ (id)shared
{
    static NWSURLParser *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSURLParser alloc] init];
    });
    return result;
}

@end
