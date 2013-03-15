//
//  NWSAssertTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSAssertTransform.h"
#import "NWAbout.h"


@implementation NWSAssertTransform


#pragma mark - Object life cycle

- (id)initWithForward:(id)forward reverse:(id)reverse
{
    self = [super init];
    if (self) {
        _forward = forward;
        _reverse = reverse;
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
    return [[self alloc] initWithValue:@(integer)];
}


#pragma mark - Transform

- (id)transform:(id)value context:(NWSMappingContext *)context
{
#if DEBUG
    if (![_forward isEqual:value]) {
        NSString *message = [NSString stringWithFormat:@"Assert transform failed on: %@ != %@", _forward, value];
        if (_logInstead) {
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
    if (![_reverse isEqual:value]) {
        NSString *message = [NSString stringWithFormat:@"Assert reverse failed on: %@ != %@", _reverse, value];
        if (_logInstead) {
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
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"assert-transform" about:prefix];
}

@end
