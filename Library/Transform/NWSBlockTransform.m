//
//  NWSBlockTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSBlockTransform.h"
#import "NWSCommon.h"


@implementation NWSBlockTransform


#pragma mark - Object life cycle

- (id)initWithBlock:(id(^)(id value, NWSMappingContext* context))transformBlock
{
    return [self initWithTransformBlock:transformBlock reverseBlock:nil];
}

- (id)initWithTransformBlock:(id(^)(id value, NWSMappingContext* context))transformBlock reverseBlock:(id(^)(id value, NWSMappingContext* context))reverseBlock
{
    self = [super init];
    if (self) {
        _transformBlock = [transformBlock copy];
        _reverseBlock = [reverseBlock copy];
    }
    return self;
}


#pragma mark - Transform

- (id)transform:(id)value context:(NWSMappingContext *)context
{
    return _transformBlock(value, context);
}

- (id)reverse:(id)value context:(NWSMappingContext *)context
{
    if(_reverseBlock){
        return _reverseBlock(value, context);
    } else {
        NWLogWarn(@"No reverseBlock set");
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p transform:%@ reverse:%@>", NSStringFromClass(self.class), self, _transformBlock ? @"Y" : @"N", _reverseBlock ? @"Y" : @"N"];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"block-transform" readable:prefix];
}


@end
