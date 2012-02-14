//
//  NWSStore.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSStore.h"
#import "NWSCommon.h"
#import "NWSPath.h"
#import "NWSObjectReference.h"


@implementation NWSStore


# pragma mark - Store stuff

// TODO: consider providing an NSPredicate instead of a NSArray of paths and values, moving the predicate creation (and caching) to the mapping
- (NWSObjectID *)identifierWithType:(NWSObjectType *)type primaryPathsAndValues:(NSArray *)pathsAndValues create:(BOOL)create // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (id)attributeForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (id)relationForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (void)setAttributeForIdentifier:(NWSObjectID *)identifier value:(id)value path:(NWSPath *)path // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
} // COV_NF_END

- (void)setRelationForIdentifier:(NWSObjectID *)identifier value:(NWSObjectID *)value path:(NWSPath *)path policy:(NWSPolicy *)policy baseStore:(NWSStore *)baseStore // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
} // COV_NF_END

- (void)deleteObjectWithIdentifier:(NWSObjectID *)identifier // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
} // COV_NF_END

- (NWSObjectReference *)referenceForIdentifier:(NWSObjectID *)identifier // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (NWSObjectID *)identifierForObject:(id)object // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (NWSObjectType *)typeFromString:(NSString *)string // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (NWSObjectID *)identifierWithType:(NSString *)type primaryPath:(NSString *)path value:(id)value
{
    NSArray *pathsAndValues = [[NSArray alloc] initWithObjects:[NWSPath pathFromString:path], value, nil];
    NWSObjectType *t = [self typeFromString:type];
    return [self identifierWithType:t primaryPathsAndValues:pathsAndValues create:NO];
}

- (id)objectWithType:(NSString *)type primaryPath:(NSString *)path value:(id)value
{
    NWSObjectID *i = [self identifierWithType:type primaryPath:path value:value];
    if (i) {
        return [[self referenceForIdentifier:i] dereference];
    }
    return nil;
}


#pragma mark - Transaction management

- (NWSStore *)beginTransaction // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (void)mergeTransaction:(NWSStore *)store // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
} // COV_NF_END


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"store" readable:prefix];
}


#if DEBUG

- (NSArray *)allObjects // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

#endif

@end
