//
//  NWSBackend.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSBackend.h"
#import "NWService.h"
#import "NWSSchedule.h"
#import "NWSOperation.h"
#import "NWSCommon.h"


@implementation NWSBackend {
    NSMutableDictionary *mappings;
    NSMutableDictionary *endpoints;
    NWSSchedule *schedule;
}


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        mappings = [[NSMutableDictionary alloc] init];
        endpoints = [[NSMutableDictionary alloc] init];
        schedule = [[NWSSchedule alloc] init];
    }
    return self;
}

- (void)dealloc
{
    for (NWSMapping *mapping in mappings.allValues) {
        [mapping breakCycles];
    }
}

#pragma mark - Accessors

- (void)setMapping:(NWSMapping *)mapping name:(NSString *)name
{
    [mappings setObject:mapping forKey:name];
}

- (void)setEndpoint:(NWSEndpoint *)endpoint name:(NSString *)name
{
    [endpoints setObject:endpoint forKey:name];
}

- (id)mappingWithName:(NSString *)name
{
    return [self mappingWithName:name createWithClass:nil];
}

- (id)endpointWithName:(NSString *)name
{
    return [self endpointWithName:name createWithClass:nil];
}

- (id)mappingWithName:(NSString *)name createWithClass:(Class)clas
{
    NWSMapping *result = [mappings objectForKey:name];
    if (!result && clas) {
        result = [[clas alloc] init];
        [mappings setObject:result forKey:name];
    }
    return result;
}

- (id)endpointWithName:(NSString *)name createWithClass:(Class)clas
{
    NWSEndpoint *result = [endpoints objectForKey:name];
    if (!result && clas) {
        result = [[clas alloc] init];
        [endpoints setObject:result forKey:name];
    }
    return result;
}

- (NSArray *)mappingNames
{
    return mappings.allKeys;
}

- (NSArray *)endpointNames
{
    return endpoints.allKeys;
}


#pragma mark - Creating calls

- (NWSCall *)callWithEndpoint:(NSString *)endpointName
{
    NWSEndpoint *endpoint = [endpoints objectForKey:endpointName];
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
    NWSScheduleItem *result = [schedule addCall:call];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCall:(NWSCall *)call repeat:(NSTimeInterval)repeat owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [schedule addCall:call repeatInterval:repeat];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCall:(NWSCall *)call afterDelay:(NSTimeInterval)delay owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [schedule addCall:call afterDelay:delay];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCall:(NWSCall *)call onDate:(NSDate *)date owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [schedule addCall:call onDate:date];
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
    NWSScheduleItem *result = [schedule addCall:[self callWithEndpoint:endpointName]];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName value:(id)value key:(NSString *)key owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [schedule addCall:[self callWithEndpoint:endpointName value:value key:key]];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [schedule addCall:[self callWithEndpoint:endpointName parameters:parameters]];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName value:(id)value key:(NSString *)key parent:(NSObject *)parent owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [schedule addCall:[self callWithEndpoint:endpointName value:value key:key parent:parent]];
    if (owner) {
        [owner addOperation:result];
    } else {
        NWLogWarn(@"Scheduling item without owner");
    }
    return result;
}

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters parent:(NSObject *)parent owner:(NWSOperationOwner *)owner
{
    NWSScheduleItem *result = [schedule addCall:[self callWithEndpoint:endpointName parameters:parameters parent:parent]];
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
    return [NSString stringWithFormat:@"<%@:%p m:%u e:%u>", NSStringFromClass(self.class), self, mappings.count, endpoints.count];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"backend with %u mappings and %u endpoints", mappings.count, endpoints.count] readable:prefix];
}

- (NSString *)about
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\n[%@]\n", NSStringFromClass(self.class)];
    [result appendFormat:@"Mappings: (#%u)\n", mappings.count];
    for (NSString *name in mappings) {
        [result appendFormat:@"   %@: %@\n", name, [[mappings objectForKey:name] readable:@"   "]];
    }
    [result appendFormat:@"Endpoints: (#%u)\n", endpoints.count];
    for (NSString *name in endpoints) {
        [result appendFormat:@"   %@: %@\n", name, [[endpoints objectForKey:name] readable:@"   "]];
    }
    [result appendFormat:@"Schedule: %@", schedule.readable];
    return result;
}

@end
