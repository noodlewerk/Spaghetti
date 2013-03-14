//
//  NWSPath.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSPath.h"
#import "NWSCommon.h"
#import "NWSSingleKeyPath.h"
#import "NWSKeyPathPath.h"
#import "NWSSelfPath.h"
#import "NWSConstantValuePath.h"
#import "NWSCompositePath.h"
#import "NWSIndexPath.h"


@implementation NWSPath


#pragma mark - Path

- (id)valueWithObject:(NSObject *)object // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (void)setWithObject:(NSObject *)object value:(id)value // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
} // COV_NF_END

- (BOOL)isEqual:(NWSPath *)path // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return NO;
} // COV_NF_END

- (NSUInteger)hash // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return NO;
} // COV_NF_END


#pragma mark - String parsing

+ (NWSPath *)pathFromString:(NSString *)string
{
    if (!string) {
        return nil;
    }
    if (!string.length) {
        return NWSSelfPath.shared;
    }
    unichar c = [string characterAtIndex:0];
    switch (c) {
        case '=': return [NWSConstantValuePath pathFromString:[string substringFromIndex:1]]; break;
        case ':': return [self pathFromString:[string substringFromIndex:1] separator:@":"]; break;
        case '.': return [[NWSKeyPathPath alloc] initWithKeyPath:string]; break;
    }
    return [self pathFromString:string separator:@"."];
}

+ (NWSPath *)componentFromString:(NSString *)string
{
    NWSPath *path = [NWSIndexPath pathFromString:string];
    if (path) {
        return path;
    }
    if ([string rangeOfString:@"."].length) {
        return [[NWSKeyPathPath alloc] initWithKeyPath:string];
    }
    return [[NWSSingleKeyPath alloc] initWithKey:string];
}

+ (NWSPath *)pathFromString:(NSString *)string separator:(NSString *)separator
{
    NSArray *components = [string componentsSeparatedByString:separator];
    if (components.count > 1) {
        NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:components.count];
        for (NSString *component in components) {
            NWSPath *path = [self componentFromString:component];
            [paths addObject:path];
        }
        return [[NWSCompositePath alloc] initWithPaths:paths];
    } else if (components.count) {
        return [self componentFromString:components[0]];
    }
    return nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"a path" readable:prefix];
}

@end



@implementation NSObject (NWSPath)

- (id)valueForPath:(NWSPath *)path
{
    return [path valueWithObject:self];
}

- (void)setValue:(id)value forPath:(NWSPath *)path
{
    [path setWithObject:self value:value];
}

- (id)valueForPathString:(NSString *)string
{
    return [[NWSPath pathFromString:string] valueWithObject:self];
}

- (void)setValue:(id)value forPathString:(NSString *)string
{
    [[NWSPath pathFromString:string] setWithObject:self value:value];
}

@end
