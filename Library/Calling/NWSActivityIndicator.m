//
//  NWSActivityIndicator.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSActivityIndicator.h"


@implementation NWSBasicActivityIndicator {
    NSUInteger count;
    BOOL showingActivity;
    dispatch_queue_t queue;
}

@synthesize switchBlock, callbackQueue, delay;


#pragma mark - Object life cycle

- (id)init
{
    return [self initWithBlock:nil callbackQueue:nil delay:0];
}

- (id)initWithBlock:(NWSActivityIndicatorSwitchBlock)_switchBlock callbackQueue:(NSOperationQueue *)_callbackQueue delay:(NSTimeInterval)_delay
{
    self = [super init];
    if (self) {
        switchBlock = [_switchBlock copy];
        callbackQueue = _callbackQueue;
        delay = _delay;
        queue = dispatch_queue_create("NWSBasicActivityIndicator", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(queue);
}

- (BOOL)activity
{
    __block BOOL result;
    dispatch_sync(queue, ^{
        result = count > 0;
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
    if (hasActivity != showingActivity) {
        showingActivity = hasActivity;
        void(^block)() = ^{
            switchBlock(hasActivity);
        };
        [callbackQueue addOperationWithBlock:block];
    }
}

- (void)update
{
    BOOL hasActivity = count > 0;
    BOOL hasDelay = delay > 0;
    if (hasActivity || !hasDelay) {
        [self showActivity:hasActivity];
    } else {
        // delay call
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_after(popTime, queue, ^(void) {
            BOOL hasActivity = count > 0;
            if (!hasActivity) {
                // still no activity, time to report
                [self showActivity:hasActivity];
            }
        });        
    }
}

- (void)registerActivity
{
    dispatch_async(queue, ^{
        count++;
        if (count == 1) {
            [self update];
        }
    });
}

- (void)unregisterActivity
{
    dispatch_async(queue, ^{
        if (count) {
            count--;
            if (count == 0) {
                [self update];
            }
        } else {
            NWLogWarn(@"Unregistering network activity once too much");
        }
    });
}

@end



@implementation NWSCombinedActivityIndicator {
    NSMutableArray *indicators;
}

@synthesize indicators;


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        indicators = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithIndicator:(id<NWSActivityIndicator>)indicator
{
    self = [super init];
    if (self) {
        indicators = [[NSMutableArray alloc] initWithObjects:indicator, nil];
    }
    return self;
}

- (id)initWithIndicators:(NSArray *)_indicators
{
    self = [super init];
    if (self) {
        indicators = [[NSMutableArray alloc] initWithArray:_indicators];
    }
    return self;
}

- (void)addIndicator:(id<NWSActivityIndicator>)indicator
{
    [indicators addObject:indicator];    
}

- (void)addIndicators:(NSArray *)_indicators
{
    [indicators addObjectsFromArray:_indicators];
}

- (id)copyWithZone:(NSZone *)zone
{
    NWSCombinedActivityIndicator *result = [[self.class allocWithZone:zone] initWithArray:indicators];
    return result;
}

#pragma mark - Activity Indicator

- (void)registerActivity
{
    for (id<NWSActivityIndicator> indicator in indicators) {
        [indicator registerActivity];
    }
}

- (void)unregisterActivity
{
    for (id<NWSActivityIndicator> indicator in indicators) {
        [indicator unregisterActivity];
    }
}

@end



@implementation NWSSloppyActivityIndicator {
    NSUInteger count;
}

@synthesize indicator;


#pragma mark - Object life cycle

- (id)initWithIndicator:(id<NWSActivityIndicator>)_indicator
{
    self = [super init];
    if (self) {
        indicator = _indicator;
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
    while (count--) {
        [indicator unregisterActivity];
    }
}

- (void)registerActivity
{
    count++;
    [indicator registerActivity];    
}

- (void)unregisterActivity
{
    if (count) {
        count--;
        [indicator unregisterActivity];
    }
}

@end



#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
static void NWSNetworkSetShowActivity(BOOL activity) {
    NSCAssert(NSThread.isMainThread, @"Network indicator should be accessed from main thread");
    NSCAssert(UIApplication.sharedApplication.networkActivityIndicatorVisible != activity, @"UIApplication's networkActivityIndicatorVisible has been changed outside of this indicator.");
    UIApplication.sharedApplication.networkActivityIndicatorVisible = activity;
}
#else
static void NWSNetworkSetShowActivity(BOOL activity) {
    // TODO: no UIApplication available to set network activity indicator
}
#endif

static NSTimeInterval const NWSNetworkActivityIndicatorDelay = 1.0;

@implementation NWSNetworkActivityIndicator


#pragma mark - Shared instance

+ (void)registerActivity
{
    [self.shared registerActivity];
}

+ (void)unregisterActivity
{
    [self.shared unregisterActivity];
}

+ (NWSNetworkActivityIndicator *)shared
{
    static NWSNetworkActivityIndicator *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSNetworkActivityIndicator alloc] initWithBlock:^(BOOL activity) {
            NWSNetworkSetShowActivity(activity);
        } callbackQueue:NSOperationQueue.mainQueue delay:NWSNetworkActivityIndicatorDelay];
    });
    return result;
}

@end
