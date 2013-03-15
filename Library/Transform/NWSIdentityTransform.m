//
//  NWSIdentityTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSIdentityTransform.h"
#import "NWAbout.h"


@implementation NWSIdentityTransform


#pragma mark - Object life cycle

+ (NWSIdentityTransform *)shared
{
    static NWSIdentityTransform *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSIdentityTransform alloc] init];
    });
    return result;
}


#pragma mark - NWSTransform

- (id)transform:(id)value context:(NWSMappingContext *)context
{
    return value;
}

- (id)reverse:(id)value context:(NWSMappingContext *)context
{
    return value;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"identity-transform" about:prefix];
}

@end
