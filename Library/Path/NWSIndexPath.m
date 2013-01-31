//
//  NWSIndexPath.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSIndexPath.h"
#import "NWSCommon.h"


@implementation NWSIndexPath

@synthesize index;


#pragma mark - Object life cycle

- (id)initWithIndex:(NSInteger)_index
{
    self = [super init];
    if (self) {
        index = _index;
    }
    return self;
}

- (BOOL)isEqual:(NWSIndexPath *)path
{
    return self == path || (self.class == path.class && self.index == path.index);
}

- (NSUInteger)hash
{
    return 1842738790 + (NSUInteger)index;
}


#pragma mark - Path

- (id)valueWithObject:(NSArray *)array
{
    if ([array isKindOfClass:NSArray.class]) {
        NSInteger i = index < 0 ? index + array.count : index;
        if (i < 0 || i >= array.count) {
            NWLogWarn(@"Index path out of bounds: %i", (int)i);
            return nil;
        }
        return [array objectAtIndex:i];
    } else if ((id)array == NSNull.null) {
        return NSNull.null; 
    } else if (array) {
        NWLogWarn(@"Expecting array to apply index path to: %@", array);
    }
    return nil;
}

- (void)setWithObject:(NSMutableArray *)array value:(id)value
{
    if ([array isKindOfClass:NSMutableArray.class]) {
        NSInteger i = index < 0 ? index + array.count : index;
        while (i >= array.count) {
            [array addObject:NSNull.null];
        }
        if (i < 0 || i >= array.count) {
            NWLogWarn(@"Index path out of bounds: %i", (int)i);
            return;
        }
        [array replaceObjectAtIndex:i withObject:value];
    } else if ((id)array == NSNull.null) {
    } else if (array)  {
        NWLogWarn(@"Expecting mutable array to apply index path to: %@", array);
    }
}


#pragma mark - String parsing

+ (NWSIndexPath *)pathFromString:(NSString *)string
{
    NSNumber *number = [string number];
    if (number) {
        return [[NWSIndexPath alloc] initWithIndex:[number integerValue]];
    }
    return nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p index:%i>", NSStringFromClass(self.class), self, (int)index];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSNumber numberWithInteger:index] readable:prefix];
}


@end
