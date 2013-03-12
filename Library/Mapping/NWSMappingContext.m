//
//  NWSMappingContext.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMappingContext.h"
#import "NWSCommon.h"
#import "NWSStore.h"
#import "NWSCompositePath.h"


@implementation NWSMappingContext {
    NSMutableArray *_done;
    NSMutableArray *_indexStack;
#if DEBUG
    NSMutableArray *_pathStack;
#endif
}


- (id)initWithStore:(NWSStore *)store
{
    self = [super init];
    if (self) {
        _store = store;
        _done = [[NSMutableArray alloc] init];
        _indexStack = [[NSMutableArray alloc] init];
#if DEBUG
        _pathStack = [[NSMutableArray alloc] init];
#endif
    }
    return self;
}


#pragma mark - Object marking

- (void)doing:(id)value
{
    [_done addObject:value];
}

- (BOOL)did:(id)value
{
    for (id i in _done) {
        if ([value isEqual:i]) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Index-in-array

- (void)pushIndexInArray
{
    [_indexStack addObject:[NSNumber numberWithUnsignedInteger:_indexInArray]];
    _indexInArray = 0;
}

- (void)incIndexInArray
{
    _indexInArray++;
}

- (void)popIndexInArray
{
    _indexInArray = [[_indexStack lastObject] unsignedIntegerValue];
    [_indexStack removeLastObject];
}

#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p store:%@>", NSStringFromClass(self.class), self, _store];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"map-context" readable:prefix];
}


#if DEBUG

- (void)pushPath:(NWSPath *)path
{
    [_pathStack addObject:path];
}

- (void)popPath
{
    [_pathStack removeLastObject];
}

- (NWSPath *)pathStack
{
    return [[NWSCompositePath alloc] initWithPaths:_pathStack];
}

- (NSString *)path
{
    return [[self pathStack] readable];
}

#else 

- (NSString *)path
{
    return @"No path available in release";
}

#endif

@end
