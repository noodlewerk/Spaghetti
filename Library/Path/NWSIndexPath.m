//
//  NWSIndexPath.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSIndexPath.h"
#import "NWSCommon.h"


@implementation NWSIndexPath


#pragma mark - Object life cycle

- (id)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _index = index;
    }
    return self;
}

- (BOOL)isEqual:(NWSIndexPath *)path
{
    return self == path || (self.class == path.class && self.index == path.index);
}

- (NSUInteger)hash
{
    return 1842738790 + (NSUInteger)_index;
}


#pragma mark - Path

- (id)valueWithObject:(NSArray *)array
{
    if ([array isKindOfClass:NSArray.class]) {
        NSInteger i = _index < 0 ? _index + array.count : _index;
        if (i < 0 || i >= array.count) {
            NWLogWarn(@"Index path out of bounds: %i", (int)i);
            return nil;
        }
        return array[i];
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
        NSInteger i = _index < 0 ? _index + array.count : _index;
        while (i >= array.count) {
            [array addObject:NSNull.null];
        }
        if (i < 0 || i >= array.count) {
            NWLogWarn(@"Index path out of bounds: %i", (int)i);
            return;
        }
        array[i] = value;
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
    return [NSString stringWithFormat:@"<%@:%p index:%i>", NSStringFromClass(self.class), self, (int)_index];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@(_index) readable:prefix];
}


@end
