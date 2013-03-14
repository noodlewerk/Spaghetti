//
//  NWSCall.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@class NWSEndpoint, NWSStore, NWSDialogue, NWSMapping, NWSPath, NWSPolicy, NWSParser;
@protocol NWSActivityIndicator;

typedef void(^NWSCallDoneBlock)(id result);

/**
 * The prototype for a specific conversation.
 *
 * Please refer to NWSEndpoint for an explanation how NWSCall relates to NWSEndpoint and NWSDialogue.
 */
@interface NWSCall : NSObject <NSCopying>

/**
 * The endpoint from which this call was derived.
 * @see [NWSEndpoint newCall]
 */
@property (nonatomic, strong) NWSEndpoint *endpoint;

/**
 * The block invoked by a dialogue to indicate success or failure.
 * @see NWSDialogue
 */
@property (nonatomic, copy) NWSCallDoneBlock doneBlock;

/**
 * A dictionary of key-value pairs used for substituting $-references.
 * @see setParameterValue:forKey:
 * @see setParameters:
 * @see dereference:parameters:
 */
@property (nonatomic, strong, readonly) NSDictionary *parameters;

/** @name Mapping */

/**
 * The store that will be used for backing the mapped objects.
 * @see [NWSEndpoint store]
 */
@property (nonatomic, strong) NWSStore *store;

/**
 * The parser that serializes outgoing data.
 */
@property (nonatomic, strong) NWSParser *requestParser;

/**
 * The mapping used to compose the request.
 * @see [NWSEndpoint requestMapping]
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
 * The mapping used to interpret the response.
 * @see [NWSEndpoint responseMapping]
 */
@property (nonatomic, strong) NWSMapping *responseMapping;

/**
 * The path in the response from where the mapping should start.
 * @see [NWSEndpoint responsePath]
 */
@property (nonatomic, strong) NWSPath *responsePath;

/** @name Parent */

/**
 * The parent object where the result with be assigned.
 * @see parentPath
 * @see parentPolicy
 */
@property (nonatomic, strong) NSObject *parent;

/**
 * The path in the parent object where the result with be assigned.
 * @see [NWSEndpoint parentPath]
 * @see parentPolicy
 */
@property (nonatomic, strong) NWSPath *parentPath;

/**
 * The path in the parent object where the result with be assigned.
 * @see [NWSEndpoint parentPolicy]
 * @see parentPath
 */
@property (nonatomic, strong) NWSPolicy *parentPolicy;

/** @name Activity */

/**
 * The activity indicator used by derived dialogues.
 * @see [NWSEndpoint indicator]
 * @see addIndicator:
 */
@property (nonatomic, strong) id<NWSActivityIndicator> indicator;

- (id)initWithEndpoint:(NWSEndpoint *)endpoint;

/**
 * Add (another) activity indicator to this call. If one is already present, both are wrapped in a NWSCombinedActivityIndicator.
 * @param indicator The indicator to be informed upon calling.
 * @see indicator;
 */
- (void)addIndicator:(id<NWSActivityIndicator>)indicator;

/** @name Setting parameters */

/**
 * Add a key-value pair to the parameters dictionary.
 * @param value  Value to be substituted in $-references to key.
 * @param key  The key in all $-references to be substituted by value.
 * @see parameters
 */
- (void)setParameterValue:(NSString *)value forKey:(NSString *)key;

/**
 * Add all key-value pairs to the parameters dictionary.
 * @param parameters Dictionary of key-value substitutions.
 * @see parameters
 */
- (void)setParameters:(NSDictionary *)parameters;

/**
 * A stand-alone tool for resolving $-references. All references that are not mentioned in the parameters dictionary will be indicated by ?-references.
 * @param format A string that may contain $-references.
 * @param parameters A dictionary that provides values for each $-reference.
 * @see parameters
 */
+ (NSString *)dereference:(NSString *)format parameters:(NSDictionary *)parameters;

/** @name Creating dialogues */

/**
 * Instantiates a dialogue based on this call.
 * @see NWSDialogue
 */
- (NWSDialogue *)newDialogue;

- (NWSDialogue *)start;

- (void)doneWithResult:(id)result;

@end
