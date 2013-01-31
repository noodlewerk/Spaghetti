//
//  NWSEndpoint.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@class NWSVarStat, NWSCall, NWSMapping,  NWSStore, NWSPath, NWSPolicy, NWSParser;
@protocol NWSActivityIndicator;

#if DEBUG
#define DEBUG_STAT_START(__stat) NSDate *__stat##DebugDate = NSDate.date
#define DEBUG_STAT_STOP(__stat, __endpoint) [(__endpoint.__stat) count:-[(__stat##DebugDate) timeIntervalSinceNow]]
#define DEBUG_STAT_INTERVAL(__stat) (-[(__stat##DebugDate) timeIntervalSinceNow])
#define DEBUG_STAT_START_IN(__date) __date = NSDate.date
#define DEBUG_STAT_STOP_IN(__date, __stat) [(__stat) count:-[(__date) timeIntervalSinceNow]]
#define DEBUG_STAT_INTERVAL_IN(__date) (-[(__date) timeIntervalSinceNow])
#else
#define DEBUG_STAT_START(__stat)
#define DEBUG_STAT_STOP(__stat, __endpoint)
#define DEBUG_STAT_INTERVAL(__stat) 0.
#define DEBUG_STAT_START_IN(__date)
#define DEBUG_STAT_STOP_IN(__date, __stat)
#define DEBUG_STAT_INTERVAL_IN(__date) 0.
#endif

/**
 * A (server) endpoint to where a call can be made.
 *
 * NWSEndpoint, NWSCall, and NWSDialogue are related, one being a prototype/abstraction of the other. An endpoint is the most abstract, configured-once and constant over time. The call represents a concrete invocation to this endpoint, the main object in getting data from a backend. The dialogue is in turn an instantiation of a call, and a use-once object, disposed after the backend returns. In most cases, production code only touches NWSEndpoint and NWSCall.
 * @see NWSHTTPEndpoint
 */
@interface NWSEndpoint : NSObject <NSCopying>

/** @name Mapping */

/**
 * The store to which the response will be mapped.
 *
 * When mapping the root element with the responseMapping, this store will be passed along recursive mapping calls.
 * Setting the store is optional. When the store has not been set or has been set to nil, a shared instance of NWSAmnesicStore will be used as the store.
 * @see NWSMapping
 * @see NWSMappingContext
 * @see [NWSCall store]
 * @see NWSAmnesicStore
 */
@property (nonatomic, strong) NWSStore *store;

/**
 * The parser that serializes outgoing data.
 */
@property (nonatomic, strong) NWSParser *requestParser;

/**
 * The mapping that will be used to reverse-map the root object with the request.
 * @see [NWSCall requestMapping]
 */
@property (nonatomic, strong) NWSMapping *requestMapping;

/**
 * The object used to compose the request.
 * @see requestMapping
 */
@property (nonatomic, strong) NSObject *requestObject;

/**
 * The parser that handles the incoming data.
 */
@property (nonatomic, strong) NWSParser *responseParser;

/**
 * The mapping that will be used to map the root element in the response.
 * Setting the mapping is optional. When the mapping has not been set or has been set to nil, the root element itself will be returned as the response.
 * @see [NWSCall responseMapping]
 */
@property (nonatomic, strong) NWSMapping *responseMapping;

/**
 * A path in the response element from which the responseMapping will be applied.
 *
 * For example, if use a response path `a.b` on the element `{"a":{"b":["c","d"]}}`, the response mapping will be applied to `["c","d"]`.
 * @see [NWSCall responsePath]
 */
@property (nonatomic, strong) NWSPath *responsePath;

/** @name Parent */

/**
 * The path on the parent object to where the response mapping result will be assigned.
 * @see [NWSCall parentPath]
 */
@property (nonatomic, strong) NWSPath *parentPath;

/**
 * The assignment policy that will be used for assigning the mapping result to the parent object.
 * @see [NWSCall parentPolicy]
 */
@property (nonatomic, strong) NWSPolicy *parentPolicy;

/** @name Activity */

/**
 * The activity indicator that will be used by calls derived from this endpoint.
 * @see [NWSCall indicator]
 */
@property (nonatomic, strong) id<NWSActivityIndicator> indicator;

/** @name Creating calls */

/**
 * Instantiates a call to this endpoint.
 * @see NWSCall
 */
- (id)newCall;

#if DEBUG
@property (nonatomic, strong) NWSVarStat *requestTime;
@property (nonatomic, strong) NWSVarStat *parseTime;
@property (nonatomic, strong) NWSVarStat *mappingTime;
@property (nonatomic, strong) NWSVarStat *totalTime;
#else
- (NWSVarStat *)requestTime;
- (NWSVarStat *)parseTime;
- (NWSVarStat *)mappingTime;
- (NWSVarStat *)totalTime;
#endif

@end
