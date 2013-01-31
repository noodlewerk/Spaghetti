//
//  NWSArrayTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSArrayTransform.h"
#import "NWSCommon.h"
#import "NWSArrayObjectID.h"
#import "NWSMappingContext.h"


@implementation NWSArrayTransform

@synthesize transform;


#pragma mark - Object life cycle

- (id)initWithTransform:(NWSTransform *)_transform
{
    self = [super init];
    if (self) {
        transform = _transform;
    }
    return self;
}


#pragma mark - NWSTransform

- (NWSArrayObjectID *)transform:(NSArray *)array context:(NWSMappingContext *)context
{
    if ([array isKindOfClass:NSArray.class]) {
        NSMutableArray *identifiers = [[NSMutableArray alloc] initWithCapacity:array.count];
        [context pushIndexInArray];
        for (id i in array) {
            id transformed = [transform transform:i context:context];
            if (transformed) {
                [identifiers addObject:transformed];
                [context incIndexInArray];
            } else {
                NWLogWarn(@"Unable to add nil to object array (untransformed:%@ path:%@)", array, context.path);
            }
        }
        [context popIndexInArray];
        NWSArrayObjectID *result = [[NWSArrayObjectID alloc] initWithIdentifiers:identifiers];
        return result;
    } else {
        NSArray *identifiers = nil;
        [context pushIndexInArray];
        id transformed = [transform transform:array context:context];
        if (transformed) {
            identifiers = @[transformed];
            [context incIndexInArray];
        } else {
            identifiers = @[];
            NWLogWarn(@"Unable to set nil to object array (untransformed:%@ path:%@)", array, context.path);
        }
        [context popIndexInArray];
        NWSArrayObjectID *result = [[NWSArrayObjectID alloc] initWithIdentifiers:identifiers];
        return result;
    }
}

- (NSArray *)reverse:(NWSArrayObjectID *)identifier context:(NWSMappingContext *)context
{
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NSArray *array = [identifier identifiers];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:array.count];
        for (id i in array) {
            id reversed = [transform reverse:i context:context];
            if (reversed) {
                [result addObject:reversed];
            } else {
                [result addObject:NSNull.null];
            }
        }
        return result;
    } else {
        NWLogWarn(@"Expecting NWSArrayObjectID instead of %@ (path:%@)", identifier.class, context.path);
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p transform:%@>", NSStringFromClass(self.class), self, transform];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"repeated %@", [transform readable:prefix]] readable:prefix];
}

@end
