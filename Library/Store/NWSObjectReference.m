//
//  NWSObjectReference.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSObjectReference.h"
#import "NWSCommon.h"


@implementation NWSObjectReference

@synthesize object;


#pragma mark - Object life cycle

- (id)initWithObject:(id)_object
{
    self = [super init];
    if (self) {
        object = _object;
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
    return [NWSObjectReference dereference:object];
}

@end
