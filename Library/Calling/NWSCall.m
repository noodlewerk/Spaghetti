//
//  NWSCall.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSCall.h"
#import "NWSCommon.h"
#import "NWSEndpoint.h"
#import "NWSActivityIndicator.h"
#import "NWSDialogue.h"

@implementation NWSCall {
    NSMutableDictionary *_parameters;
}


#pragma mark - Object life cycle

- (id)initWithEndpoint:(NWSEndpoint *)endpoint
{
    self = [super init];
    if (self) {
        _endpoint = endpoint;
        _store = endpoint.store;
        _requestParser = endpoint.requestParser;
        _requestMapping = endpoint.requestMapping;
        _requestObject = endpoint.requestObject;
        _responseParser = endpoint.responseParser;
        _responseMapping = endpoint.responseMapping;
        _responsePath = endpoint.responsePath;
        _parentPath = endpoint.parentPath;
        _parentPolicy = endpoint.parentPolicy;
        _indicator = endpoint.indicator;
    }
    return self;
}

- (NWSDialogue *)newDialogue // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (NWSDialogue *)start
{
    NWSDialogue *dialogue = [self newDialogue];
    [dialogue start];
    return dialogue;
}

- (id)copyWithZone:(NSZone *)zone
{
    NWSCall *result = [[self.class allocWithZone:zone] init];
    result.endpoint = _endpoint;
    result.block = _block;
    result.parameters = [_parameters mutableCopy];
    result.store = _store;
    result.requestParser = _requestParser;
    result.requestMapping = _requestMapping;
    result.requestObject = _requestObject;
    result.responseParser = _responseParser;
    result.responseMapping = _responseMapping;
    result.responsePath = _responsePath;
    result.parent = _parent;
    result.parentPath = _parentPath;
    result.parentPolicy = _parentPolicy;
    if ([_indicator isKindOfClass:NWSCombinedActivityIndicator.class]) {
        result.indicator = [(NWSCombinedActivityIndicator *)_indicator copy];
    } else {
        result.indicator = _indicator;
    }
    return result;
}

- (void)doneWithResult:(id)result
{
    if (_block) {
        void(^b)(id result) = _block;
        _block = nil;
        b(result);
    }
}


#pragma mark - Accessors

- (void)setParameterValue:(NSString *)value forKey:(NSString *)key
{
    if (!_parameters) {
        _parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:value, key, nil];
    } else {
        _parameters[key] = value;
    }
}

- (void)setParameters:(NSDictionary *)parameters
{
    if (!_parameters) {
        _parameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    } else {
        [_parameters addEntriesFromDictionary:parameters];
    }
}

- (void)addIndicator:(id<NWSActivityIndicator>)indicator
{
    NWLogWarnIfNot(_indicator, @"Expecting non-nil indicator to add");
    if ([_indicator isKindOfClass:NWSCombinedActivityIndicator.class]) {
        [(NWSCombinedActivityIndicator *)_indicator addIndicator:indicator];
    } else if (_indicator) {
        _indicator = [[NWSCombinedActivityIndicator alloc] initWithIndicators:@[indicator, indicator]];
    } else {
        _indicator = indicator;
    }
}


#pragma mark - Tooling

+ (NSRange)range:(NSString *)format index:(NSUInteger)index type:(char *)type
{
    static const char types[2] = {'$', '%'};
    NSRange result = NSMakeRange(NSNotFound, 0);
    for (NSUInteger i = 0; i < sizeof(types); i++) {
        NSRange r = [format rangeOfString:[NSString stringWithFormat:@"%c(", types[i]] options:0 range:NSMakeRange(index, format.length - index)];
        if (r.length && r.location < result.location) {
            result = r;
            if (type) {
                *type = types[i];
            }
        }
    }
    return result;
}

+ (NSString *)dereference:(NSString *)format parameters:(NSDictionary *)parameters
{
    if (![self range:format index:0 type:NULL].length) {
        return format;
    }
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < format.length;) {
        char type = '\0';
        NSRange r = [self range:format index:i type:&type];
        if (r.length) {
            NSString *append = [format substringWithRange:NSMakeRange(i, r.location - i)];
            [result appendString:append];
            i = r.location + r.length;
        } else {
            NSString *append = [format substringFromIndex:i];
            [result appendString:append];
            break;
        }
        NSRange s = [format rangeOfString:@")" options:0 range:NSMakeRange(i, format.length - i)];
        if (s.length) {
            NSString *key = [format substringWithRange:NSMakeRange(i, s.location - i)];
            id value = parameters[key];
            if (value) {
                if (type == '%') {
                    value = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)value, NULL, CFSTR("*'();:@&=+$,/?!%#[]"), kCFStringEncodingUTF8);
                }
                [result appendString:[value description]];
            } else {
                NWLogWarn(@"Unable to find value for key: %@", key);
                [result appendFormat:@"?(%@)", key];
            }
            i = s.location + s.length;
        } else {
            NWLogWarn(@"$(..) is missing closing parenthesis in format: %@", format);
            break;
        }
    }
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p endpoint:%@>", NSStringFromClass(self.class), self, _endpoint];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"call to %@", _endpoint] readable:prefix];
}

@end
