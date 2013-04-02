//
//  NWActivityIndicator.m
//  NWTools
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWActivityIndicator.h"
#include "NWLCore.h"


@implementation NWBasicActivityIndicator {
    NSUInteger _count;
    BOOL _showingActivity;
    dispatch_queue_t _queue;
}


#pragma mark - Object life cycle

- (id)init
{
    return [self initWithBlock:nil callbackQueue:nil delay:0];
}

- (id)initWithBlock:(void(^)(BOOL activity))switchBlock callbackQueue:(NSOperationQueue *)callbackQueue delay:(NSTimeInterval)delay
{
    self = [super init];
    if (self) {
        _switchBlock = [switchBlock copy];
        _callbackQueue = callbackQueue;
        _delay = delay;
        _queue = dispatch_queue_create("NWBasicActivityIndicator", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_queue);
}

- (BOOL)activity
{
    __block BOOL result;
    dispatch_sync(_queue, ^{
        result = _count > 0;
    });
    return result;
}


#pragma mark - Activity reporting

- (void)showActivity:(BOOL)hasActivity
{
    if (!self.callbackQueue) {
        NWLogWarn(@"Expecting non-nil callbackQueue, to use for activity indication");
        return;
    }
    if (!self.switchBlock) {
        NWLogWarn(@"Expecting non-nil switchBlock, to call with activity indication");
        return;
    }
    if (hasActivity != _showingActivity) {
        _showingActivity = hasActivity;
        void(^block)() = ^{
            _switchBlock(hasActivity);
        };
        [_callbackQueue addOperationWithBlock:block];
    }
}

- (void)update
{
    BOOL hasActivity = _count > 0;
    BOOL hasDelay = _delay > 0;
    if (hasActivity || !hasDelay) {
        [self showActivity:hasActivity];
    } else {
        // delay call
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _delay * NSEC_PER_SEC);
        dispatch_after(popTime, _queue, ^(void) {
            BOOL hasActivity = _count > 0;
            if (!hasActivity) {
                // still no activity, time to report
                [self showActivity:hasActivity];
            }
        });        
    }
}

- (void)registerActivity
{
    dispatch_async(_queue, ^{
        _count++;
        if (_count == 1) {
            [self update];
        }
    });
}

- (void)unregisterActivity
{
    dispatch_async(_queue, ^{
        if (_count) {
            _count--;
            if (_count == 0) {
                [self update];
            }
        } else {
            NWLogWarn(@"Unregistering network activity once too much");
        }
    });
}

@end



@implementation NWCombinedActivityIndicator {
    NSMutableArray *_indicators;
}


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        _indicators = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithIndicator:(id<NWActivityIndicator>)indicator
{
    self = [super init];
    if (self) {
        _indicators = [[NSMutableArray alloc] initWithObjects:indicator, nil];
    }
    return self;
}

- (id)initWithIndicators:(NSArray *)indicators
{
    self = [super init];
    if (self) {
        _indicators = [[NSMutableArray alloc] initWithArray:indicators];
    }
    return self;
}

- (void)addIndicator:(id<NWActivityIndicator>)indicator
{
    [_indicators addObject:indicator];    
}

- (void)addIndicators:(NSArray *)indicators
{
    [_indicators addObjectsFromArray:indicators];
}

- (id)copyWithZone:(NSZone *)zone
{
    NWCombinedActivityIndicator *result = [[self.class allocWithZone:zone] initWithArray:_indicators];
    return result;
}

#pragma mark - Activity Indicator

- (void)registerActivity
{
    for (id<NWActivityIndicator> indicator in _indicators) {
        [indicator registerActivity];
    }
}

- (void)unregisterActivity
{
    for (id<NWActivityIndicator> indicator in _indicators) {
        [indicator unregisterActivity];
    }
}

@end



@implementation NWSloppyActivityIndicator {
    NSUInteger _count;
}


#pragma mark - Object life cycle

- (id)initWithIndicator:(id<NWActivityIndicator>)indicator
{
    self = [super init];
    if (self) {
        _indicator = indicator;
    }
    return self;
}

- (void)dealloc
{
    [self unregisterRemainingActivity];
}


#pragma mark - Activity indication

- (void)unregisterRemainingActivity
{
    while (_count--) {
        [_indicator unregisterActivity];
    }
}

- (void)registerActivity
{
    _count++;
    [_indicator registerActivity];    
}

- (void)unregisterActivity
{
    if (_count) {
        _count--;
        [_indicator unregisterActivity];
    }
}

@end



#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
static void NWNetworkSetShowActivity(BOOL activity) {
    NWLogWarnIfNot(NSThread.isMainThread, @"Network indicator should be accessed from main thread");
    NWLogWarnIfNot(UIApplication.sharedApplication.networkActivityIndicatorVisible != activity, @"UIApplication's networkActivityIndicatorVisible has been changed outside of this indicator.");
    UIApplication.sharedApplication.networkActivityIndicatorVisible = activity;
}
#else
static void NWNetworkSetShowActivity(BOOL activity) {
    // TODO: no UIApplication available to set network activity indicator
}
#endif

static NSTimeInterval const NWNetworkActivityIndicatorDelay = 1.0;

@implementation NWNetworkActivityIndicator


#pragma mark - Shared instance

+ (void)registerActivity
{
    [self.shared registerActivity];
}

+ (void)unregisterActivity
{
    [self.shared unregisterActivity];
}

+ (NWNetworkActivityIndicator *)shared
{
    static NWNetworkActivityIndicator *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWNetworkActivityIndicator alloc] initWithBlock:^(BOOL activity) {
            NWNetworkSetShowActivity(activity);
        } callbackQueue:NSOperationQueue.mainQueue delay:NWNetworkActivityIndicatorDelay];
    });
    return result;
}

@end
