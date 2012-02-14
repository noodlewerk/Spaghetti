//
//  NWSStringToNumberTransform.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSStringToNumberTransform.h"
#import "NWSCommon.h"
#import "NWSMappingContext.h"


@implementation NWSStringToNumberTransform


#pragma mark - Object life cycle

+ (NWSStringToNumberTransform *)shared
{
    static NWSStringToNumberTransform *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSStringToNumberTransform alloc] init];
    });
    return result;
}


#pragma mark - NWSTransform

- (id)transform:(NSString *)string context:(NWSMappingContext *)context
{
    if ([string isKindOfClass:NSString.class]) {
        return [string number];
    } else if (string) {
        NWLogWarn(@"Expecting NSString instead of %@ (path:%@)", string.class, context.path);
    }
    return nil;
}

- (id)reverse:(NSNumber *)number context:(NWSMappingContext *)context
{
    if ([number isKindOfClass:NSNumber.class]) {
        return [number stringValue];
    } else if (number) {
        NWLogWarn(@"Expecting NSNumber instead of %@ (path:%@)", number.class, context.path);
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
    return [@"string-to-number" readable:prefix];
}

@end
