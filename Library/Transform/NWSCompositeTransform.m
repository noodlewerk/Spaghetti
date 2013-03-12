//
//  NWSCompositeTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSCompositeTransform.h"
#import "NWSCommon.h"


@implementation NWSCompositeTransform {
    NSMutableArray *_transforms;
}


#pragma mark - Object life cycle

- (id)initWithTransforms:(NSArray *)transforms
{
    self = [super init];
    if (self) {
        _transforms = [[NSMutableArray alloc] initWithArray:transforms];
    }
    return self;
}


#pragma mark - NWSTransform

- (id)transform:(id)value context:(NWSMappingContext *)context
{
    for (NWSTransform *transform in _transforms) {
        value = [transform transform:value context:context];
    }
    return value;
}

- (id)reverse:(id)value context:(NWSMappingContext *)context
{
    for (NWSTransform *transform in _transforms) {
        value = [transform reverse:value context:context];
    }
    return value;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p #transforms:%u>", NSStringFromClass(self.class), self, (int)_transforms.count];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"compound %@", [_transforms readable:prefix]] readable:prefix];
}

@end
