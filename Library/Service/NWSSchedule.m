//
//  NWSSchedule.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSSchedule.h"
#import "NWSCall.h"
#import "NWSDialogue.h"
#import "NWSCommon.h"


static const NSTimeInterval minOperationInterval = 0.1;


@interface NWSScheduleItem ()
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval intervalTime;
@property (nonatomic, strong) NSOperationQueue *callbackQueue;
@property (nonatomic, assign) BOOL cancelled;
- (void)start:(NSOperationQueue *)queue;
@end

@implementation NWSScheduleItem

@synthesize startTime, intervalTime, callbackQueue, cancelled;


#pragma mark - Schedule Item

- (void)start:(NSOperationQueue *)queue // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
} // COV_NF_END

- (void)cancel // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
} // COV_NF_END


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p s:%f i:%f q:%@>", NSStringFromClass(self.class), self, startTime, intervalTime, callbackQueue ? @"Y" : @"N"];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"schedule-item-abstract" readable:prefix];
}

@end


/**
 *
 */
@interface NWSCallScheduleItem : NWSScheduleItem
@property (nonatomic, strong) NWSCall *call;
- (id)initWithCall:(NWSCall *)call;
@end

@implementation NWSCallScheduleItem {
    NWSDialogue *dialogue;
}

@synthesize call;


#pragma mark - Object life cycle

- (id)initWithCall:(NWSCall *)_call
{
    self = [super init];
    if (self) {
        call = _call;
    }
    return self;
}


#pragma mark - Schedule Item

- (void)start:(NSOperationQueue *)queue
{
    dialogue = [call newDialogue];
    dialogue.operationQueue = queue;
    dialogue.callbackQueue = self.callbackQueue;
    [dialogue start];
}

- (void)cancel
{
    self.cancelled = YES;
    [dialogue cancel];
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p s:%f i:%f q:%@>", NSStringFromClass(self.class), self, self.startTime, self.intervalTime, self.callbackQueue ? @"Y" : @"N"];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"schedule-item on:%@ every:%u call:%@", [NSDate dateWithTimeIntervalSince1970:self.startTime], (NSInteger)self.intervalTime, [call readable:prefix]] readable:prefix];
}

@end



@implementation NWSGroupedScheduleItem

@synthesize items;


#pragma mark - Object life cycle

- (id)initWithItemArray:(NSArray *)_items
{
    self = [super init];
    if (self) {
        items = _items;
    }
    return self;
}

- (id)initWithItems:(NWSScheduleItem *)item, ...
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, item);
    for (NWSScheduleItem *arg = item; arg != nil; arg = va_arg(args, NWSScheduleItem *)) {
        [array addObject:arg];
    }
    va_end(args);
    return [self initWithItemArray:array];
}


#pragma mark - Schedule Item

- (void)start:(NSOperationQueue *)queue
{
    for (NWSScheduleItem *item in items) {
        [item start:queue];
    }    
}

- (void)cancel
{
    self.cancelled = YES;
    for (NWSScheduleItem *item in items) {
        [item cancel];
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p s:%f i:%f q:%@>", NSStringFromClass(self.class), self, self.startTime, self.intervalTime, self.callbackQueue ? @"Y" : @"N"];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"schedule-group on:%@ every:%u #%u", [NSDate dateWithTimeIntervalSince1970:self.startTime], (NSInteger)self.intervalTime, items.count] readable:prefix];
}

@end


@implementation NWSSchedule {
    NSOperationQueue *operationQueue;
    dispatch_queue_t scheduleQueue;
    NSMutableArray *schedule;
    BOOL cancelled;
    NSRunLoop *runloop;
    NSDate *nextRun;
}

- (id)init
{
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        scheduleQueue = dispatch_queue_create("NWSSchedule", DISPATCH_QUEUE_SERIAL);
        schedule = [[NSMutableArray alloc] init];
   }
    return self;
}

- (void)dealloc
{
    dispatch_release(scheduleQueue); scheduleQueue = nil;
}

- (void)queueItem:(NWSScheduleItem *)item
{
    NWLogInfo(@"on-queue: queueing item");
    // TODO: more efficient sorted insert
    [schedule addObject:item];
    [schedule sortUsingComparator:^NSComparisonResult(NWSScheduleItem *a, NWSScheduleItem *b) {
        if (a.startTime < b.startTime) {
            return NSOrderedAscending;
        } else if (a.startTime > b.startTime) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    NSTimeInterval now = [NSDate.date timeIntervalSince1970];
    NSTimeInterval delay = item.startTime - now;
    [self dequeueItemAfterDelay:delay];
}

- (void)dequeueItemAfterDelay:(NSTimeInterval)delay
{
    delay = MAX(delay, 0);
    NSDate *next = [NSDate dateWithTimeIntervalSinceNow:delay];
    if (!nextRun || [next compare:nextRun] == NSOrderedAscending) {
        NWLogInfo(@"on-queue: re-run");
        nextRun = next;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_after(popTime, scheduleQueue, ^(void) {
            [self dequeueItem];
        });
    }
}


- (void)dequeueItem
{
    nextRun = nil;
    if (cancelled) {
        NWLogInfo(@"on-queue: cancelled");
        return;
    }
    if (schedule.count) {
        NWSScheduleItem *item = [schedule objectAtIndex:0];
        NSTimeInterval now = [NSDate.date timeIntervalSince1970];
        NSTimeInterval delay = item.startTime - now;
        if (delay <= 0) {
            // update schedule
            NWLogInfo(@"on-queue: running item");
            [schedule removeObjectAtIndex:0];
            if (!item.cancelled) {
                if (item.intervalTime > 0) {
                    item.startTime = now + item.intervalTime;
                    [self queueItem:item];
                }
                // run item
                [item start:operationQueue];
            }
            // schedule next
            if (schedule.count) {
                NWSScheduleItem *next = [schedule objectAtIndex:0];
                [self dequeueItemAfterDelay:next.startTime - now + minOperationInterval];
            } else {
                NWLogInfo(@"on-queue: pausing");
            }
        } else {
            NWLogInfo(@"on-queue: retry in %f", delay);
            [self dequeueItemAfterDelay:delay];
        }
    } else {
        NWLogInfo(@"on-queue: pausing (2)");
    }
}

- (void)start
{
    NWLogInfo(@"off-queue: starting");
    dispatch_async(scheduleQueue, ^{
        cancelled = NO;
    });
}

- (void)cancel
{
    NWLogInfo(@"off-queue: cancelling");
    dispatch_async(scheduleQueue, ^{
        cancelled = YES;
    });
}

- (void)scheduleItem:(NWSScheduleItem *)item
{
    NWLogInfo(@"off-queue: adding item");
    if (!item.callbackQueue) {
        item.callbackQueue = NSOperationQueue.currentQueue;
    }
    dispatch_async(scheduleQueue, ^{
        [self queueItem:item];
    });
}

- (NSUInteger)count
{
    __block NSUInteger result = 0;
    dispatch_sync(scheduleQueue, ^{
        result = schedule.count;
    });
    return result;
}

- (BOOL)running
{
    __block BOOL result = NO;
    dispatch_sync(scheduleQueue, ^{
        result = !cancelled;
    });
    return result;
}

- (NWSScheduleItem *)addCall:(NWSCall *)call
{
    return [self addCall:call afterDelay:0 repeatInterval:0];
}

- (NWSScheduleItem *)addCall:(NWSCall *)call repeatInterval:(NSTimeInterval)interval
{
    return [self addCall:call afterDelay:0 repeatInterval:interval];
}

- (NWSScheduleItem *)addCall:(NWSCall *)call afterDelay:(NSTimeInterval)delay
{
    return [self addCall:call afterDelay:delay repeatInterval:0];
}

- (NWSScheduleItem *)addCall:(NWSCall *)call onDate:(NSDate *)date
{
    return [self addCall:call afterDelay:[date timeIntervalSinceNow] repeatInterval:0];
}

- (NWSScheduleItem *)addCall:(NWSCall *)call afterDelay:(NSTimeInterval)delay repeatInterval:(NSTimeInterval)interval
{
    NWLogWarnIfNot(call, @"Expecting call to be non-nil");
    NWSScheduleItem *result = [[NWSCallScheduleItem alloc] initWithCall:call];
    result.startTime = [NSDate.date timeIntervalSince1970] + delay;
    result.intervalTime = interval;
    result.callbackQueue = NSOperationQueue.currentQueue;
    [self scheduleItem:result];
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p #%u %@>", NSStringFromClass(self.class), self, self.count, self.running ? @"R" : @"P"];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"schedule %@ with %u items", self.running ? @"running" : @"paused", self.count] readable:prefix];
}

- (NSString *)about
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\n[%@]\n", NSStringFromClass(self.class)];
    dispatch_sync(scheduleQueue, ^{
        [result appendFormat:@"Currently %@ with %u scheduled calls.\n", cancelled ? @"paused" : @"running", schedule.count];
        [result appendFormat:@"Next run will be on %@.\n", nextRun];
        [result appendString:@"Scheduled items:\n"];
        for (NWSScheduleItem *item in schedule) {
            [result appendFormat:@"   %@\n", [item readable:@"   "]];
        }
    });
    return result;
}

@end
