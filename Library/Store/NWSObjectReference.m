//
//  NWSObjectReference.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSObjectReference.h"
#import "NWSCommon.h"


@implementation NWSObjectReference


#pragma mark - Object life cycle

- (id)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        _object = object;
    }
    return self;
}


#pragma mark - Referencing

+ (id)dereference:(id)object
{
    return [object mapWithBlock:^(NWSObjectReference *reference) {
        if ([reference isKindOfClass:NWSObjectReference.class]) {
            return [self dereference:reference.object];
        }
        return (id)reference;
    }];
}

- (id)dereference
{
    return [NWSObjectReference dereference:_object];
}

@end
