//
//  NWSCall.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSCall.h"
#import "NWSCommon.h"
#import "NWSEndpoint.h"
#import "NWSActivityIndicator.h"

@implementation NWSCall {
    NSMutableDictionary *parameters;
}

@synthesize endpoint, doneBlock, parameters, store;
@synthesize requestParser, requestMapping, requestObject, responseParser, responseMapping, responsePath;
@synthesize parent, parentPath, parentPolicy;
@synthesize indicator;


#pragma mark - Object life cycle

- (id)initWithEndpoint:(NWSEndpoint *)_endpoint
{
    self = [super init];
    if (self) {
        endpoint = _endpoint;
        store = _endpoint.store;
        requestParser = _endpoint.requestParser;
        requestMapping = _endpoint.requestMapping;
        requestObject = _endpoint.requestObject;
        responseParser = _endpoint.responseParser;
        responseMapping = _endpoint.responseMapping;
        responsePath = _endpoint.responsePath;
        parentPath = _endpoint.parentPath;
        parentPolicy = _endpoint.parentPolicy;
        indicator = _endpoint.indicator;
    }
    return self;
}

- (id)newDialogue // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (id)copyWithZone:(NSZone *)zone
{
    NWSCall *result = [[self.class allocWithZone:zone] init];
    result.endpoint = endpoint;
    result.doneBlock = doneBlock;
    result.parameters = [parameters mutableCopy];
    result.store = store;
    result.requestParser = requestParser;
    result.requestMapping = requestMapping;
    result.requestObject = requestObject;
    result.responseParser = responseParser;
    result.responseMapping = responseMapping;
    result.responsePath = responsePath;
    result.parent = parent;
    result.parentPath = parentPath;
    result.parentPolicy = parentPolicy;
    if ([indicator isKindOfClass:NWSCombinedActivityIndicator.class]) {
        result.indicator = [(NWSCombinedActivityIndicator *)indicator copy];
    } else {
        result.indicator = indicator;
    }
    return result;
}


#pragma mark - Accessors

- (void)setParameterValue:(NSString *)value forKey:(NSString *)key
{
    if (!parameters) {
        parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:value, key, nil];
    } else {
        [parameters setObject:value forKey:key];
    }
}

- (void)setParameters:(NSDictionary *)_parameters
{
    if (!parameters) {
        parameters = [[NSMutableDictionary alloc] initWithDictionary:_parameters];
    } else {
        [parameters addEntriesFromDictionary:_parameters];
    }
}

- (void)addIndicator:(id<NWSActivityIndicator>)_indicator
{
    NWLogWarnIfNot(_indicator, @"Expecting non-nil indicator to add");
    if ([indicator isKindOfClass:NWSCombinedActivityIndicator.class]) {
        [(NWSCombinedActivityIndicator *)indicator addIndicator:_indicator];
    } else if (indicator) {
        indicator = [[NWSCombinedActivityIndicator alloc] initWithIndicators:[NSArray arrayWithObjects:indicator, _indicator, nil]];
    } else {
        indicator = _indicator;
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
            id value = [parameters objectForKey:key];
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
    return [NSString stringWithFormat:@"<%@:%p endpoint:%@>", NSStringFromClass(self.class), self, endpoint];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"call to %@", endpoint] readable:prefix];
}

@end
