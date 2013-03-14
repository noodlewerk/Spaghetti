//
//  NWSEndpoint.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSEndpoint.h"
#import "NWSCommon.h"
#import "NWSVarStat.h"
#import "NWSSelfPath.h"
#import "NWSCall.h"
#import "NWSParser.h"

@implementation NWSEndpoint


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
#if DEBUG
        _mappingTime = [[NWSVarStat alloc] init];
        _parseTime = [[NWSVarStat alloc] init];
        _totalTime = [[NWSVarStat alloc] init];
        _requestTime = [[NWSVarStat alloc] init];
#endif
    }
    return self;
}

- (id)newCall // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (NWSCall *)startWithBlock:(void (^)(id result))block
{
    return [self startWithParameters:nil block:block];
}

- (NWSCall *)startWithParameters:(NSDictionary *)parameters block:(void (^)(id result))block
{
    NWSCall *call = [self newCall];
    call.block = block;
    if (parameters) [call setParameters:parameters];
    [call start];
    return call;
}

- (id)copyWithZone:(NSZone *)zone
{
    NWSEndpoint *result = [[self.class allocWithZone:zone] init];
    result.store = _store;
    result.requestParser = _requestParser;
    result.requestMapping = _requestMapping;
    result.requestObject = _requestObject;
    result.responseParser = _responseParser;
    result.responseMapping = _responseMapping;
    result.responsePath = _responsePath;
    result.parentPath = _parentPath;
    result.parentPolicy = _parentPolicy;
    result.indicator = _indicator;
    return result;
}

#if !DEBUG
- (NWSVarStat *)mappingTime {return nil;}
- (NWSVarStat *)parseTime {return nil;}
- (NWSVarStat *)totalTime {return nil;}
- (NWSVarStat *)requestTime {return nil;}
#endif

#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"endpoint" readable:prefix];
}

@end
