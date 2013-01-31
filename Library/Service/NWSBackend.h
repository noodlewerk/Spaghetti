//
//  NWSBackend.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@class NWSCall, NWSEndpoint, NWSMapping, NWSScheduleItem, NWSOperationOwner;


/**
 * A comfortable entrance point to NWService, NWSBackend represents the backend being serviced by providing all endpoints, calls and mapping it contains.
 *
 * By fully configuring a backend on application startup, making a call becomes a small effort. All calls, but also mappings and endpoints, will be available under their given name, which provides a descriptive tag.
 *
 * @see NWSCall
 * @see NWSSchedule
 * @see NWSEndpoint
 * @see NWSMapping
 */
@interface NWSBackend : NSObject

/** @name Managing mappings and endpoints */

/**
 * The collection of mapping names.
 * @see mappingWithName:
 */
@property (nonatomic, readonly) NSArray *mappingNames;

/**
 * The collection of endpoint names.
 * @see endpointWithName:
 */
@property (nonatomic, readonly) NSArray *endpointNames;

@property (nonatomic, strong) Class defaultMappingClass;
@property (nonatomic, strong) Class defaultEndpointClass;

/**
 * Stores a mapping under a given name.
 * @param mapping The subject mapping.
 * @param name A descriptive name used for retrieval.
 * @see mappingWithName:
 */
- (void)setMapping:(NWSMapping *)mapping name:(NSString *)name;

/**
 * Stores an endpoint under a given name.
 * @param endpoint The subject endpoint.
 * @param name A descriptive name used for retrieval.
 * @see endpointWithName:
 */
- (void)setEndpoint:(NWSEndpoint *)endpoint name:(NSString *)name;

/**
 * Retrieves a mapping by its given name.
 * @param name A descriptive name used for retrieval.
 * @see setMapping:name:
 * @see mappingWithName:createWithClass:
 */
- (id)mappingWithName:(NSString *)name;

/**
 * Retrieves an endpoint by its given name.
 * @param name A descriptive name used for retrieval.
 * @see setEndpoint:name:
 * @see endpointWithName:createWithClass:
 */
- (id)endpointWithName:(NSString *)name;

/**
 * Retrieves a mapping by its given name, or creates one if none present.
 * @param name A descriptive name used for retrieval.
 * @param clas The class to instantiate.
 * @see setMapping:name:
 * @see mappingWithName:createWithClass:
 */
- (id)mappingWithName:(NSString *)name createWithClass:(Class)clas;

/**
 * Retrieves an endpoint by its given name, or creates one if none present.
 * @param name A descriptive name used for retrieval.
 * @param clas The class to instantiate.
 * @see setEndpoint:name:
 * @see endpointWithName:createWithClass:
 */
- (id)endpointWithName:(NSString *)name createWithClass:(Class)clas;


/** @name Creating calls */

- (NWSCall *)callWithEndpoint:(NSString *)endpoint;
- (NWSCall *)callWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key;
- (NWSCall *)callWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters;
- (NWSCall *)callWithEndpoint:(NSString *)endpoint value:(id)value key:(NSString *)key parent:(id)parent;
- (NWSCall *)callWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters parent:(id)parent;


/** @name Scheduling calls */

- (NWSScheduleItem *)scheduleCall:(NWSCall *)call owner:(NWSOperationOwner *)owner;
- (NWSScheduleItem *)scheduleCall:(NWSCall *)call repeat:(NSTimeInterval)repeat owner:(NWSOperationOwner *)owner;
- (NWSScheduleItem *)scheduleCall:(NWSCall *)call afterDelay:(NSTimeInterval)delay owner:(NWSOperationOwner *)owner;
- (NWSScheduleItem *)scheduleCall:(NWSCall *)call onDate:(NSDate *)date owner:(NWSOperationOwner *)owner;

- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName owner:(NWSOperationOwner *)owner;
- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName value:(id)value key:(NSString *)key owner:(NWSOperationOwner *)owner;
- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters owner:(NWSOperationOwner *)owner;
- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName value:(id)value key:(NSString *)key parent:(NSObject *)parent owner:(NWSOperationOwner *)owner;
- (NWSScheduleItem *)scheduleCallWithEndpoint:(NSString *)endpointName parameters:(NSDictionary *)parameters parent:(NSObject *)parent owner:(NWSOperationOwner *)owner;

- (NSString *)about;

@end
