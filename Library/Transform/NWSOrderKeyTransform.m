//
//  NWSOrderKeyTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSOrderKeyTransform.h"
#import "NWAbout.h"
#import "NWSMappingContext.h"


@implementation NWSOrderKeyTransform


#pragma mark - Object life cycle

- (id)init
{
    return [self initWithBegin:0 step:1];
}

- (id)initWithBegin:(NSInteger)begin step:(NSInteger)step
{
    self = [super init];
    if (self) {
        _begin = begin;
        _step = step;
    }
    return self;
}

+ (NWSOrderKeyTransform *)shared
{
    static NWSOrderKeyTransform *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSOrderKeyTransform alloc] init];
    });
    return result;
}


#pragma mark - NWSTransform

- (id)transform:(id)value context:(NWSMappingContext *)context
{
    NSInteger order = context.indexInArray * _step + _begin;
    return @(order);
}

- (id)reverse:(id)value context:(NWSMappingContext *)context
{
    // no need to reverse transform order keys
    return nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"order-key-transform" about:prefix];
}

@end
