//
//  NWSBlockTransform.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSBlockTransform.h"
#import "NWSCommon.h"


@implementation NWSBlockTransform

@synthesize transformBlock, reverseBlock;


#pragma mark - Object life cycle

- (id)initWithBlock:(NWSTransformBlock)_transformBlock
{
    return [self initWithTransformBlock:_transformBlock reverseBlock:nil];
}

- (id)initWithTransformBlock:(NWSTransformBlock)_transformBlock reverseBlock:(NWSTransformBlock)_reverseBlock
{
    self = [super init];
    if (self) {
        transformBlock = [_transformBlock copy];
        reverseBlock = [_reverseBlock copy];
    }
    return self;
}


#pragma mark - Transform

- (id)transform:(id)value context:(NWSMappingContext *)context
{
    return transformBlock(value, context);
}

- (id)reverse:(id)value context:(NWSMappingContext *)context
{
    if(reverseBlock){
        return reverseBlock(value, context);
    } else {
        NWLogWarn(@"No reverseBlock set");
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p transform:%@ reverse:%@>", NSStringFromClass(self.class), self, transformBlock ? @"Y" : @"N", reverseBlock ? @"Y" : @"N"];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"block-transform" readable:prefix];
}


@end
