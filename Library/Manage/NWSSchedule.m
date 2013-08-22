//
//  NWSSchedule.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSSchedule.h"
#import "NWSCall.h"
#import "NWSDialogue.h"
#import "NWAbout.h"
#include "NWLCore.h"


static const NSTimeInterval minOperationInterval = 0.1;


@interface NWSScheduleItem ()
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval intervalTime;
@property (nonatomic, strong) NSOperationQueue *callbackQueue;
@property (nonatomic, assign) BOOL cancelled;
- (void)start:(NSOperationQueue *)queue;
@end

@implementation NWSScheduleItem


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
    return [NSString stringWithFormat:@"<%@:%p s:%f i:%f q:%@>", NSStringFromClass(self.class), self, _startTime, _intervalTime, _callbackQueue ? @"Y" : @"N"];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"schedule-item-abstract" about:prefix];
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
    NWSDialogue *_dialogue;
}


#pragma mark - Object life cycle

- (id)initWithCall:(NWSCall *)call
{
    self = [super init];
    if (self) {
        _call = call;
    }
    return self;
}


#pragma mark - Schedule Item

- (void)start:(NSOperationQueue *)queue
{
    _dialogue = [_call newDialogue];
    _dialogue.operationQueue = queue;
    _dialogue.callbackQueue = self.callbackQueue;
    [_dialogue start];
}

- (void)cancel
{
    self.cancelled = YES;
    [_dialogue cancel];
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p s:%f i:%f q:%@>", NSStringFromClass(self.class), self, self.startTime, self.intervalTime, self.callbackQueue ? @"Y" : @"N"];
}

- (NSString *)about:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"schedule-item on:%@ every:%u call:%@", [NSDate dateWithTimeIntervalSince1970:self.startTime], (int)self.intervalTime, [_call about:prefix]] about:prefix];
}

@end



@implementation NWSGroupedScheduleItem


#pragma mark - Object life cycle

- (id)initWithItemArray:(NSArray *)items
{
    self = [super init];
    if (self) {
        _items = items;
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
    for (NWSScheduleItem *item in _items) {
        [item start:queue];
    }    
}

- (void)cancel
{
    self.cancelled = YES;
    for (NWSScheduleItem *item in _items) {
        [item cancel];
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p s:%f i:%f q:%@>", NSStringFromClass(self.class), self, self.startTime, self.intervalTime, self.callbackQueue ? @"Y" : @"N"];
}

- (NSString *)about:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"schedule-group on:%@ every:%u #%u", [NSDate dateWithTimeIntervalSince1970:self.startTime], (int)self.intervalTime, (int)_items.count] about:prefix];
}

@end


@implementation NWSSchedule {
    NSOperationQueue *_operationQueue;
    dispatch_queue_t _scheduleQueue;
    NSMutableArray *_schedule;
    BOOL _cancelled;
    NSRunLoop *_runloop;
    NSDate *_nextRun;
}

- (id)init
{
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _scheduleQueue = dispatch_queue_create("NWSSchedule", DISPATCH_QUEUE_SERIAL);
        _schedule = [[NSMutableArray alloc] init];
   }
    return self;
}

- (void)dealloc
{
    dispatch_release(_scheduleQueue); _scheduleQueue = nil;
}

- (void)queueItem:(NWSScheduleItem *)item
{
    NWLogSpag(@"on-queue: queueing item");
    // TODO: more efficient sorted insert
    [_schedule addObject:item];
    [_schedule sortUsingComparator:^NSComparisonResult(NWSScheduleItem *a, NWSScheduleItem *b) {
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
    if (!_nextRun || [next compare:_nextRun] == NSOrderedAscending) {
        NWLogSpag(@"on-queue: re-run");
        _nextRun = next;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_after(popTime, _scheduleQueue, ^(void) {
            [self dequeueItem];
        });
    }
}


- (void)dequeueItem
{
    _nextRun = nil;
    if (_cancelled) {
        NWLogSpag(@"on-queue: cancelled");
        return;
    }
    if (_schedule.count) {
        NWSScheduleItem *item = _schedule[0];
        NSTimeInterval now = [NSDate.date timeIntervalSince1970];
        NSTimeInterval delay = item.startTime - now;
        if (delay <= 0) {
            // update schedule
            NWLogSpag(@"on-queue: running item");
            [_schedule removeObjectAtIndex:0];
            if (!item.cancelled) {
                if (item.intervalTime > 0) {
                    item.startTime = now + item.intervalTime;
                    [self queueItem:item];
                }
                // run item
                [item start:_operationQueue];
            }
            // schedule next
            if (_schedule.count) {
                NWSScheduleItem *next = _schedule[0];
                [self dequeueItemAfterDelay:next.startTime - now + minOperationInterval];
            } else {
                NWLogSpag(@"on-queue: pausing");
            }
        } else {
            NWLogSpag(@"on-queue: retry in %f", delay);
            [self dequeueItemAfterDelay:delay];
        }
    } else {
        NWLogSpag(@"on-queue: pausing (2)");
    }
}

- (void)start
{
    NWLogSpag(@"off-queue: starting");
    dispatch_async(_scheduleQueue, ^{
        _cancelled = NO;
    });
}

- (void)cancel
{
    NWLogSpag(@"off-queue: cancelling");
    dispatch_async(_scheduleQueue, ^{
        _cancelled = YES;
    });
}

- (void)scheduleItem:(NWSScheduleItem *)item
{
    NWLogSpag(@"off-queue: adding item");
    if (!item.callbackQueue) {
        item.callbackQueue = NSOperationQueue.currentQueue;
    }
    dispatch_async(_scheduleQueue, ^{
        [self queueItem:item];
    });
}

- (NSUInteger)count
{
    __block NSUInteger result = 0;
    dispatch_sync(_scheduleQueue, ^{
        result = _schedule.count;
    });
    return result;
}

- (BOOL)running
{
    __block BOOL result = NO;
    dispatch_sync(_scheduleQueue, ^{
        result = !_cancelled;
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
    return [NSString stringWithFormat:@"<%@:%p #%u %@>", NSStringFromClass(self.class), self, (int)self.count, self.running ? @"R" : @"P"];
}

- (NSString *)about:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"schedule %@ with %u items", self.running ? @"running" : @"paused", (int)self.count] about:prefix];
}

- (NSString *)about
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\n[%@]\n", NSStringFromClass(self.class)];
    dispatch_sync(_scheduleQueue, ^{
        [result appendFormat:@"Currently %@ with %u scheduled calls.\n", _cancelled ? @"paused" : @"running", (int)_schedule.count];
        [result appendFormat:@"Next run will be on %@.\n", _nextRun];
        [result appendString:@"Scheduled items:\n"];
        for (NWSScheduleItem *item in _schedule) {
            [result appendFormat:@"   %@\n", [item about:@"   "]];
        }
    });
    return result;
}

@end
