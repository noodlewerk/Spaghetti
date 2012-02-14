//
//  NWSAssertTransform.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSAssertTransform.h"
#import "NWSCommon.h"


@implementation NWSAssertTransform

@synthesize forward, reverse, logInstead;


#pragma mark - Object life cycle

- (id)initWithForward:(id)_forward reverse:(id)_reverse
{
    self = [super init];
    if (self) {
        forward = _forward;
        reverse = _reverse;
    }
    return self;
}

- (id)initWithValue:(id)value
{
    return [self initWithForward:value reverse:value];
}


#pragma mark - Convenience

+ (id)transformWithValue:(id)value
{
    return [[self alloc] initWithValue:value];
}

+ (id)transformWithInteger:(NSInteger)integer
{
    return [[self alloc] initWithValue:[NSNumber numberWithInteger:integer]];
}


#pragma mark - Transform

- (id)transform:(id)value context:(NWSMappingContext *)context
{
#if DEBUG
    if (![forward isEqual:value]) {
        NSString *message = [NSString stringWithFormat:@"Assert transform failed on: %@ != %@", forward, value];
        if (logInstead) {
            NWLogWarn(@"%@", message);
        } else {
            NSAssert(NO, @"%@", message);        
        }
    }
#endif
    return value;
}

- (id)reverse:(id)value context:(NWSMappingContext *)context
{
#if DEBUG
    if (![reverse isEqual:value]) {
        NSString *message = [NSString stringWithFormat:@"Assert reverse failed on: %@ != %@", reverse, value];
        if (logInstead) {
            NWLogWarn(@"%@", message);
        } else {
            NSAssert(NO, @"%@", message);        
        }
    }
#endif
    return value;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class)];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"assert-transform" readable:prefix];
}

@end
