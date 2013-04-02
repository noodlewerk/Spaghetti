//
//  NWSSchedule.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSOperation.h"

@class NWSCall;

/**
 * A handle to a scheduled task, allowing it to be canceled.
 *
 * @see NWSSchedule
 * @see NWSOperation
 */
@interface NWSScheduleItem : NSObject<NWSOperation>

@end


/**
 * A collection of schedule items that can be accessed as one.
 */
@interface NWSGroupedScheduleItem : NWSScheduleItem

/** @name Accessing the group */

/**
 * The item collection of this group.
 * @see NWSScheduleItem
 */
@property (nonatomic, strong, readonly) NSArray *items;

/** @name Initializing the group */

/**
 * Inits this group with a collection of items.
 * @param items The items of the group.
 */
- (id)initWithItemArray:(NSArray *)items;

/**
 * Inits this group with a collection of items.
 * @param item The items of the group.
 * @param ... The items of the group.
 */
- (id)initWithItems:(NWSScheduleItem *)item, ... NS_REQUIRES_NIL_TERMINATION;

@end


/**
 * A queue-based scheduler that runs calls at specific times.
 */
@interface NWSSchedule : NSObject

/** @name Controlling the loop */

/**
 * Starts the internal scheduling loop.
 */
- (void)start;

/**
 * Pauses the internal scheduling loop, postponing the running of any calls.
 */
- (void)cancel;

/** @name Accessing the schedule */

/**
 * The number of items currently scheduled.
 */
- (NSUInteger)count;


- (BOOL)running;

/** @name Scheduling calls */

/**
 * Schedule a call to be run immediately.
 * @param call The call to run.
 * @see NWSCall
 */
- (NWSScheduleItem *)addCall:(NWSCall *)call;

/**
 * Schedule a call to be run immediately and repeatedly.
 * @param call The call to run.
 * @param interval If positive, repeat this call every interval.
 * @see NWSCall
 */
- (NWSScheduleItem *)addCall:(NWSCall *)call repeatInterval:(NSTimeInterval)interval;

/**
 * Schedule a call to be run after a delay.
 * @param call The call to run.
 * @param delay Seconds to wait before running.
 * @see NWSCall
 */
- (NWSScheduleItem *)addCall:(NWSCall *)call afterDelay:(NSTimeInterval)delay;

/**
 * Schedule a call to be run on a certain date.
 * @param call The call to run.
 * @param date Date to run, if passed, this runs immediately.
 * @see NWSCall
 */
- (NWSScheduleItem *)addCall:(NWSCall *)call onDate:(NSDate *)date;

/**
 * Schedule a call to be run after a delay and repeatedly.
 * @param call The call to run.
 * @param delay Seconds to wait before running.
 * @param interval If positive, repeat this call every interval.
 * @see NWSCall
 */
- (NWSScheduleItem *)addCall:(NWSCall *)call afterDelay:(NSTimeInterval)delay repeatInterval:(NSTimeInterval)interval;

- (NSString *)about;

@end
