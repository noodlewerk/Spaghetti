//
//  NWSObjectReference.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSObjectReference.h"
#import "NWAbout.h"


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



@implementation NSObject (MapAdditions)

- (id)mapWithBlock:(id(^)(id))block
{
    if (![self isKindOfClass:NSArray.class]) {
        return block(self);
    }
    NSArray *objects = (NSArray *)self;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (id object in objects) {
        id mapped = [object mapWithBlock:block];
        if (mapped) {
            [result addObject:mapped];
        } else {
            [result addObject:NSNull.null];
        }
    }
    return result;
}

@end