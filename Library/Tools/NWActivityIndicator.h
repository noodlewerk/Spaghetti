//
//  NWActivityIndicator.h
//  NWTools
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Something that keeps track (registers) activities.
 *
 * For example something that keeps track of the number of active operations, or something that shows a spinner as long as there are active operations.
 *
 * @see NWBasicActivityIndicator
 */
@protocol NWActivityIndicator <NSObject>

/** @name Registering activity */

/**
 * Marks the start of a particular network activity.
 * @see [NWNetworkActivityIndicator registerActivity]
 */
- (void)registerActivity;

/**
 * Marks the end of the network activity that was previously marked with registerActivity.
 * @see [NWNetworkActivityIndicator unregisterActivity]
 */
- (void)unregisterActivity;

@end


/**
 * An implementation of the NWNetworkActivityIndicator protocol based on a simple callback and a delay.
 *
 * @see NWActivityIndicator
 */
@interface NWBasicActivityIndicator : NSObject <NWActivityIndicator>

/** @name Configuring indicator */

/**
 * The block that is called when activity switches from some to none or back.
 * @see NWNetworkActivityIndicator
 */
@property (nonatomic, copy) void(^switchBlock)(BOOL activity);

/**
 * The queue on which the switch block will be invoked.
 * @see switchBlock
 */
@property (nonatomic, strong) NSOperationQueue *callbackQueue;

/**
 * The minimum number of seconds the indicator switches on.
 *
 * This prevents the indication under control to flicker on a sequence of short activities, but instead has a steady indication of at least `delay` seconds.
 * @see NWNetworkActivityIndicator
 */
@property (nonatomic, assign) NSTimeInterval delay;

/** @name Accessing indicator */

/**
 * The current activity, YES if at least one activity is registered.
 * @see NWActivityIndicator
 */
@property (nonatomic, assign, readonly) BOOL activity;

/** @name Initializing indicator */

/**
 * Inits all this indicator's properties.
 * @param switchBlock The block that is called when activity switches from some to none or back.
 * @param callbackQueue The queue on which the switch block will be invoked.
 * @param delay The minimum number of seconds the indicator switches on.
 * @see NWActivityIndicator
 */
- (id)initWithBlock:(void(^)(BOOL activity))switchBlock callbackQueue:(NSOperationQueue *)callbackQueue delay:(NSTimeInterval)delay;

@end


/**
 * A collection of activity indicators that can be accesses as one.
 *
 * All calls to registerActivity and unregisterActivity will be forwarded to its sub-indicators.
 *
 * @see NWActivityIndicator
 */
@interface NWCombinedActivityIndicator : NSObject <NWActivityIndicator, NSCopying>

/** @name Accessing indicator */

/**
 * The collection of sub-indicators to which all (un)register messages will be forwarded.
 * @see NWActivityIndicator
 */
@property (nonatomic, strong, readonly) NSArray *indicators;

/** @name Initializing indicator */

/**
 * Inits and adds one indicator.
 * @param indicator The first sub-indicator in this combined indicator.
 * @see addIndicator:
 */
- (id)initWithIndicator:(id<NWActivityIndicator>)indicator;

/**
 * Inits and adds a collection of indicators.
 * @param indicators The first sub-indicators in this combined indicator.
 * @see addIndicators:
 */
- (id)initWithIndicators:(NSArray *)indicators;

/** @name Adding sub-indicators */

/**
 * Adds one indicator to the collection of indicators
 * @param indicator Indicator to add.
 * @see initWithIndicator:
 */
- (void)addIndicator:(id<NWActivityIndicator>)indicator;

/**
 * Adds multiple indicators to the collection of indicators
 * @param indicators Indicators to add.
 * @see initWithIndicators:
 */
- (void)addIndicators:(NSArray *)indicators;

@end


/**
 * The sloppy indicator allows for sloppy indicator handling by automatically compensating for missing register and unregister calls.
 */
@interface NWSloppyActivityIndicator : NSObject <NWActivityIndicator>

/**
 * The indicator that is wrapped by this sloppy indicator.
 */
@property (nonatomic, strong, readonly) id<NWActivityIndicator> indicator;

/**
 * Inits with the indicator to-be wrapped.
 * @param indicator The indicator that is wrapped by this sloppy indicator.
 */
- (id)initWithIndicator:(id<NWActivityIndicator>)indicator;

/**
 * Unregister any remaining activity, i.e. repeatedly call unregisterActivity as necessary.
 */
- (void)unregisterRemainingActivity;

@end


/**
 * Makes sure the status bar network activity indicator is visible as long as there are activities registered.
 *
 * This indicator is built around the networkActivityIndicatorVisible property of UIApplication.sharedApplication, but does not make any assumptions of its value. It is however important to avoid any other process to modify this property to guarantee correct indication of activity by this class. This indicator will assert on this condition.
 *
 * This indicator is based on the NWBasicActivityIndicator and configured with a delay of one second, to avoid flickering activity indication.
 *
 * On non-UIKit platforms, this class does register activity, but has no means of indicating this.
 *
 * @see NWActivityIndicator
 */
@interface NWNetworkActivityIndicator : NWBasicActivityIndicator

/** @name Registering network activity */

/**
 * Forwards register message to the shared instance.
 * @see shared
 */
+ (void)registerActivity;

/**
 * Forwards unregister message to the shared instance.
 * @see shared
 */
+ (void)unregisterActivity;

/**
 * The shared instance for the one-and-only indicator.
 * @see NWBasicActivityIndicator
 */
+ (NWNetworkActivityIndicator *)shared;

@end

