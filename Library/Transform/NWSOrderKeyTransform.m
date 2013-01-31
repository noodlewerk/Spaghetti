//
//  NWSOrderKeyTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSOrderKeyTransform.h"
#import "NWSCommon.h"
#import "NWSMappingContext.h"


@implementation NWSOrderKeyTransform

@synthesize begin, step;


#pragma mark - Object life cycle

- (id)init
{
    return [self initWithBegin:0 step:1];
}

- (id)initWithBegin:(NSInteger)_begin step:(NSInteger)_step
{
    self = [super init];
    if (self) {
        begin = _begin;
        step = _step;
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
    NSInteger order = context.indexInArray * step + begin;
    return [NSNumber numberWithInteger:order];
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

- (NSString *)readable:(NSString *)prefix
{
    return [@"order-key-transform" readable:prefix];
}

@end
