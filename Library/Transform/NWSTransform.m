//
//  NWSTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"
#import "NWSCommon.h"
#import "NWSCompositeTransform.h"


@implementation NWSTransform


#pragma mark - NWSTransform

- (id)transform:(id)value context:(NWSMappingContext *)context // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (id)reverse:(id)value context:(NWSMappingContext *)context // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END


#pragma mark - Composing

- (NWSTransform *)composeWith:(NWSTransform *)transform
{
    NSMutableArray *transforms = [[NSMutableArray alloc] initWithCapacity:2];
    if ([self isKindOfClass:NWSCompositeTransform.class]) {
        NWSCompositeTransform *t = (NWSCompositeTransform *)self;
        [transforms addObjectsFromArray:t.transforms];
    } else {
        [transforms addObject:self];
    }
    if ([transform isKindOfClass:NWSCompositeTransform.class]) {
        NWSCompositeTransform *t = (NWSCompositeTransform *)transform;
        [transforms addObjectsFromArray:t.transforms];
    } else {
        [transforms addObject:transform];
    }
    NWSCompositeTransform *result = [[NWSCompositeTransform alloc] initWithTransforms:transforms];
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"transform" readable:prefix];
}

@end
