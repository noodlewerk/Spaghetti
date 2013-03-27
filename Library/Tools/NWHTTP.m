//
//  NWHTTP.m
//  NWTools
//
//  Created by Leo on 10/5/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWHTTP.h"


@implementation NWHTTP


#pragma mark - Content-type: application/x-www-form-urlencoded

+ (void)addFormDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    NSString *query = [self joinQueryWithDictionary:parameters];
    request.HTTPBody = [query dataUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - Content-type: multipart/form-data

+ (void)addMultipartDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request
{
    NSString *boundary = nil;
    NSData *post = [self multipartDataWithParameters:parameters boundary:&boundary];
    [request setValue:[@"multipart/form-data; boundary=" stringByAppendingString:boundary] forHTTPHeaderField:@"Content-type"];
    request.HTTPBody = post;
}

+ (NSData *)multipartDataWithParameters:(NSDictionary *)parameters boundary:(NSString **)boundary
{
    NSMutableData *result = [[NSMutableData alloc] init];
    if (boundary && !*boundary) {
        char buffer[32];
        for (NSUInteger i = 0; i < 32; i++) buffer[i] = "0123456789ABCDEF"[arc4random() % 16];
        NSString *random = [[NSString alloc] initWithBytes:buffer length:32 encoding:NSASCIIStringEncoding];
        *boundary = [NSString stringWithFormat:@"NWTools--%@", random];
    }
    NSData *newline = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *boundaryData = [[NSString stringWithFormat:@"--%@\r\n", boundary ? *boundary : @""] dataUsingEncoding:NSUTF8StringEncoding];
    
    for (NSArray *pair in [self flatten:parameters]) {
        [result appendData:boundaryData];
        [self appendToMultipartData:result key:pair[0] value:pair[1]];
        [result appendData:newline];
    }
    NSString *end = [NSString stringWithFormat:@"--%@--\r\n", boundary ? *boundary : @""];
    [result appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    return result;
}

+ (void)appendToMultipartData:(NSMutableData *)data key:(NSString *)key value:(id)value
{
    if ([value isKindOfClass:NSData.class]) {
        key = [key stringByReplacingOccurrencesOfString:@"%5B" withString:@"["];
        key = [key stringByReplacingOccurrencesOfString:@"%5D" withString:@"]"];
        key = [key stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
        NSString *name = key;
        NSRange r = [key rangeOfString:@"/"];
        if (r.length) {
            key = [key substringFromIndex:r.location + r.length];
            name = [name substringToIndex:r.location];
        }
        NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", name, key];
        [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:value];
    } else {
        NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, value];
        [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
}


#pragma mark - URL

+ (NSString *)urlWithBase:(NSString *)root path:(NSArray *)path query:(NSDictionary *)query
{
    NSMutableString *result = [[NSMutableString alloc] initWithString:root];
    if (path) {
        if (![result hasSuffix:@"/"]) [result appendString:@"/"];
        [result appendString:[self joinPathWithArray:path]];
    }
    if (query) {
        if (![result rangeOfString:@"?"].length) [result appendString:@"?"];
        else if (![result hasSuffix:@"?"] && ![result hasSuffix:@"&"]) [result appendString:@"&"];
        [result appendString:[self joinQueryWithDictionary:query]];
    }
    return result;
}

+ (NSString *)joinPathWithArray:(NSArray *)array
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (id component in array) {
        if (result.length) [result appendString:@"/"];
        [result appendString:[self escape:[component description]]];
    }
    return result;
}

+ (NSString *)joinQueryWithDictionary:(NSDictionary *)dictionary
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSArray *pair in [self flatten:dictionary]) {
        if (result.length) [result appendString:@"&"];
        [result appendString:pair[0]];
        [result appendString:@"="];
        [result appendString:[self escape:[pair[1] description]]];
    }
    return result;
}

+ (NSDictionary *)splitQueryWithString:(NSString *)string {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *pair in [string componentsSeparatedByString:@"&"]) {
        if (pair.length) {
            NSRange r = [pair rangeOfString:@"="];
            if (r.location == NSNotFound) {
                [pairs addObject:@[pair, @""]];
            } else {
                NSString *value = [self unescape:[pair substringFromIndex:r.location + r.length]];
                [pairs addObject:@[[pair substringToIndex:r.location], value]];
            }
        }
    }
    NSDictionary *result = [self unflatten:pairs];
    return result;
}


#pragma mark - Helpers

+ (NSString *)unescape:(NSString *)string
{
    return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), kCFStringEncodingUTF8));
}

+ (NSString *)escape:(NSString *)string
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, CFSTR("*'();:@&=+$,/?!%#[]"), kCFStringEncodingUTF8));
}

+ (NSArray *)flatten:(NSDictionary *)dictionary
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:dictionary.count];
    NSArray *keys = [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        id value = [dictionary objectForKey:key];
        if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:NSSet.class]) {
            NSString *k = [[self escape:key] stringByAppendingString:@"[]"];
            for (id v in value) {
                [result addObject:@[k, v]];
            }
        } else if ([value isKindOfClass:NSDictionary.class]) {
            for (NSString *k in value) {
                NSString *kk = [[self escape:key] stringByAppendingFormat:@"[%@]", [self escape:k]];
                [result addObject:@[kk, [value valueForKey:k]]];
            }
        } else {
            [result addObject:@[[self escape:key], value]];
        }
    }
    return result;
}

+ (NSDictionary *)unflatten:(NSArray *)array
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:array.count];
    for (NSArray *pair in array) {
        NSString *key = pair.count ? [self unescape:pair[0]] : @"";
        id value = pair.count > 1 ? pair[1] : @"";
        NSRange range = [key rangeOfString:@"["];
        if (range.length && [key hasSuffix:@"]"]) {
            NSUInteger index = range.location;
            range.location += range.length;
            range.length = key.length - range.location - 1;
            NSString *k = [key substringWithRange:range];
            key = [key substringToIndex:index];
            id current = [result objectForKey:key];
            if (k.length) {
                if ([current isKindOfClass:NSMutableDictionary.class]) {
                    [(NSMutableDictionary *)current setValue:value forKey:k];
                } else {
                    [result setValue:[NSMutableDictionary dictionaryWithDictionary:@{k:value}] forKey:key];
                }
            } else {
                if ([current isKindOfClass:NSMutableArray.class]) {
                    [(NSMutableArray *)current addObject:value];
                } else {
                    [result setValue:[NSMutableArray arrayWithArray:@[value]] forKey:key];
                }
            }
        } else {
            [result setValue:value forKey:key];
        }
    }
    return result;
}

@end
