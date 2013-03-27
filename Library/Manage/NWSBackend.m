//
//  NWSBackend.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSBackend.h"
#import "Spaghetti.h"
#import "NWSSchedule.h"
#import "NWSOperation.h"
#import "NWAbout.h"


@implementation NWSBackend {
    NSMutableDictionary *_mappings;
    NSMutableDictionary *_endpoints;
    NWSSchedule *_schedule;
}


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        _mappings = [[NSMutableDictionary alloc] init];
        _endpoints = [[NSMutableDictionary alloc] init];
        _schedule = [[NWSSchedule alloc] init];
        _defaultEndpointClass = [NWSHTTPEndpoint class];
        _defaultMappingClass = [NWSMapping class];
    }
    return self;
}

- (void)dealloc
{
    for (NWSMapping *mapping in _mappings.allValues) {
        [mapping breakCycles];
    }
}

#pragma mark - Accessors

- (void)setMapping:(NWSMapping *)mapping name:(NSString *)name
{
    _mappings[name] = mapping;
}

- (void)setEndpoint:(NWSEndpoint *)endpoint name:(NSString *)name
{
    _endpoints[name] = endpoint;
}

- (id)mappingWithName:(NSString *)name
{
    return [self mappingWithName:name createWithClass:_defaultMappingClass];
}

- (id)endpointWithName:(NSString *)name
{
    return [self endpointWithName:name createWithClass:_defaultEndpointClass];
}

- (id)mappingWithName:(NSString *)name createWithClass:(Class)clas
{
    NWSMapping *result = _mappings[name];
    if (!result && clas) {
        result = [[clas alloc] init];
        _mappings[name] = result;
    }
    return result;
}

- (id)endpointWithName:(NSString *)name createWithClass:(Class)clas
{
    NWSEndpoint *result = _endpoints[name];
    if (!result && clas) {
        result = [[clas alloc] init];
        _endpoints[name] = result;
    }
    return result;
}

- (NSArray *)mappingNames
{
    return _mappings.allKeys;
}

- (NSArray *)endpointNames
{
    return _endpoints.allKeys;
}


#pragma mark - Creating calls

- (NWSCall *)callWithEndpoint:(NSString *)endpoint
{
    return [self callWithEndpoint:endpoint block:nil];
}

- (NWSCall *)callWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key
{
    return [self callWithEndpoint:endpoint value:value key:key block:nil];
}

- (NWSCall *)callWithEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters
{
    return [self callWithEndpoint:endpoint parameters:parameters block:nil];
}

- (NWSCall *)callWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key parent:(id)parent
{
    return [self callWithEndpoint:endpoint value:value key:key parent:parent block:nil];
}

- (NWSCall *)callWithEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters parent:(id)parent
{
    return [self callWithEndpoint:endpoint parameters:parameters parent:parent block:nil];
}


- (NWSCall *)callWithEndpoint:(NSString *)endpoint block:(void(^)(id result))block
{
    NWSCall *result = [_endpoints[endpoint] newCall];
    result.block = block;
    return result;
}

- (NWSCall *)callWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key block:(void(^)(id result))block
{
    NWSCall *result = [self callWithEndpoint:endpoint];
    if (value && key) {
        [result setParameterValue:value forKey:key];
    } else {
        NWLogWarn(@"Expecting both a key and a value to be set");
    }
    result.block = block;
    return result;
}

- (NWSCall *)callWithEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters block:(void(^)(id result))block
{
    NWSCall *result = [self callWithEndpoint:endpoint];
    if (parameters) {
        [result setParameters:parameters];
    } else {
        NWLogWarn(@"Expecting parameters to be set");
    }
    result.block = block;
    return result;
}

- (NWSCall *)callWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key parent:(NSObject *)parent block:(void(^)(id result))block
{
    NWSCall *result = [self callWithEndpoint:endpoint value:value key:key];
    result.parent = parent;
    result.block = block;
    return result;
}

- (NWSCall *)callWithEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters parent:(NSObject *)parent block:(void(^)(id result))block
{
    NWSCall *result = [self callWithEndpoint:endpoint parameters:parameters];
    result.parent = parent;
    result.block = block;
    return result;
}


#pragma mark - Scheduling calls

- (NWSScheduleItem *)scheduleCall:(NWSCall *)call owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:call];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCall:(NWSCall *)call repeat:(NSTimeInterval)repeat owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:call repeatInterval:repeat];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCall:(NWSCall *)call afterDelay:(NSTimeInterval)delay owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:call afterDelay:delay];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCall:(NWSCall *)call onDate:(NSDate *)date owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:call onDate:date];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}


#pragma mark - Scheduling convenience

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint owner:(NWSOperationOwner *)owner
{
    return [self scheduleCallWithEndpoint:endpoint owner:owner block:nil];
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key owner:(NWSOperationOwner *)owner
{
    return [self scheduleCallWithEndpoint:endpoint value:value key:key owner:owner block:nil];
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters owner:(NWSOperationOwner *)owner
{
    return [self scheduleCallWithEndpoint:endpoint parameters:parameters owner:owner block:nil];
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key parent:(NSObject *)parent owner:(NWSOperationOwner *)owner
{
    return [self scheduleCallWithEndpoint:endpoint value:value key:key parent:parent owner:owner block:nil];
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters parent:(NSObject *)parent owner:(NWSOperationOwner *)owner
{
    return [self scheduleCallWithEndpoint:endpoint parameters:parameters parent:parent owner:owner block:nil];
}


- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint owner:(NWSOperationOwner *)owner block:(void(^)(id result))block
{
    NWSCall *call = [self callWithEndpoint:endpoint];
    call.block = block;
    NWSScheduleItem *result = [_schedule addCall:call];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key owner:(NWSOperationOwner *)owner block:(void(^)(id result))block
{
    NWSCall *call = [self callWithEndpoint:endpoint value:value key:key];
    call.block = block;
    NWSScheduleItem *result = [_schedule addCall:call];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters owner:(NWSOperationOwner *)owner block:(void(^)(id result))block
{
    NWSCall *call = [self callWithEndpoint:endpoint parameters:parameters];
    call.block = block;
    NWSScheduleItem *result = [_schedule addCall:call];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key parent:(NSObject *)parent owner:(NWSOperationOwner *)owner block:(void(^)(id result))block
{
    NWSCall *call = [self callWithEndpoint:endpoint value:value key:key parent:parent];
    call.block = block;
    NWSScheduleItem *result = [_schedule addCall:call];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters parent:(NSObject *)parent owner:(NWSOperationOwner *)owner block:(void(^)(id result))block
{
    NWSCall *call = [self callWithEndpoint:endpoint parameters:parameters parent:parent];
    call.block = block;
    NWSScheduleItem *result = [_schedule addCall:call];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p m:%u e:%u>", NSStringFromClass(self.class), self, (int)_mappings.count, (int)_endpoints.count];
}

- (NSString *)about:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"backend with %u mappings and %u endpoints", (int)_mappings.count, (int)_endpoints.count] about:prefix];
}

- (NSString *)about
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\n[%@]\n", NSStringFromClass(self.class)];
    [result appendFormat:@"Mappings: (#%u)\n", (int)_mappings.count];
    for (NSString *name in _mappings) {
        [result appendFormat:@"   %@: %@\n", name, [_mappings[name] about:@"   "]];
    }
    [result appendFormat:@"Endpoints: (#%u)\n", (int)_endpoints.count];
    for (NSString *name in _endpoints) {
        [result appendFormat:@"   %@: %@\n", name, [_endpoints[name] about:@"   "]];
    }
    [result appendFormat:@"Schedule: %@", _schedule.about];
    return result;
}

@end
