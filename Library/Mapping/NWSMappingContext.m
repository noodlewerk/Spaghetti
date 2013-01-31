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
    NSMutableArray *done;
    NSMutableArray *indexStack;
#if DEBUG
    NSMutableArray *pathStack;
#endif
}

@synthesize store, indexInArray;

- (id)initWithStore:(NWSStore *)_store
{
    self = [super init];
    if (self) {
        store = _store;
        done = [[NSMutableArray alloc] init];
        indexStack = [[NSMutableArray alloc] init];
#if DEBUG
        pathStack = [[NSMutableArray alloc] init];
#endif
    }
    return self;
}


#pragma mark - Object marking

- (void)doing:(id)value
{
    [done addObject:value];
}

- (BOOL)did:(id)value
{
    for (id i in done) {
        if ([value isEqual:i]) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Index-in-array

- (void)pushIndexInArray
{
    [indexStack addObject:[NSNumber numberWithUnsignedInteger:indexInArray]];
    indexInArray = 0;
}

- (void)incIndexInArray
{
    indexInArray++;
}

- (void)popIndexInArray
{
    indexInArray = [[indexStack lastObject] unsignedIntegerValue];
    [indexStack removeLastObject];
}

#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p store:%@>", NSStringFromClass(self.class), self, store];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"map-context" readable:prefix];
}


#if DEBUG

- (void)pushPath:(NWSPath *)path
{
    [pathStack addObject:path];
}

- (void)popPath
{
    [pathStack removeLastObject];
}

- (NWSPath *)pathStack
{
    return [[NWSCompositePath alloc] initWithPaths:pathStack];
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
