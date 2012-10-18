//
//  NWSCompositeTransform.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSCompositeTransform.h"
#import "NWSCommon.h"


@implementation NWSCompositeTransform {
    NSMutableArray *transforms;
}

@synthesize transforms;


#pragma mark - Object life cycle

- (id)initWithTransforms:(NSArray *)_transforms
{
    self = [super init];
    if (self) {
        transforms = [[NSMutableArray alloc] initWithArray:_transforms];
    }
    return self;
}


#pragma mark - NWSTransform

- (id)transform:(id)value context:(NWSMappingContext *)context
{
    for (NWSTransform *transform in transforms) {
        value = [transform transform:value context:context];
    }
    return value;
}

- (id)reverse:(id)value context:(NWSMappingContext *)context
{
    for (NWSTransform *transform in transforms) {
        value = [transform reverse:value context:context];
    }
    return value;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p #transforms:%u>", NSStringFromClass(self.class), self, (int)transforms.count];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"compound %@", [transforms readable:prefix]] readable:prefix];
}

@end
