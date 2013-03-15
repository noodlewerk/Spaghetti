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

- (NWSCall *)callWithEndpoint:(NSString *)endpointName
{
    NWSEndpoint *endpoint = _endpoints[endpointName];
    NWSCall *result = [endpoint newCall];
    return result;
}

- (NWSCall *)callWithEndpoint:(NSString *)endpointName value:(id)value key:(NSString *)key
{
    NWSCall *result = [self callWithEndpoint:endpointName];
    if (value && key) {
        [result setParameterValue:value forKey:key];
    } else {
        NWLogWarn(@"Expecting both a key and a value to be set");
    }
    return result;
}

- (NWSCall *)callWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters
{
    NWSCall *result = [self callWithEndpoint:endpointName];
    if (parameters) {
        [result setParameters:parameters];
    } else {
        NWLogWarn(@"Expecting parameters to be set");
    }
    return result;
}

- (NWSCall *)callWithEndpoint:(NSString *)endpointName value:(id)value key:(NSString *)key parent:(NSObject *)parent
{
    NWSCall *result = [self callWithEndpoint:endpointName value:value key:key];
    result.parent = parent;
    return result;
}

- (NWSCall *)callWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters parent:(NSObject *)parent
{
    NWSCall *result = [self callWithEndpoint:endpointName parameters:parameters];
    result.parent = parent;
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

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:[self callWithEndpoint:endpointName]];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName value:(id)value key:(NSString *)key owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:[self callWithEndpoint:endpointName value:value key:key]];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:[self callWithEndpoint:endpointName parameters:parameters]];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName value:(id)value key:(NSString *)key parent:(NSObject *)parent owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:[self callWithEndpoint:endpointName value:value key:key parent:parent]];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters parent:(NSObject *)parent owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [_schedule addCall:[self callWithEndpoint:endpointName parameters:parameters parent:parent]];
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
