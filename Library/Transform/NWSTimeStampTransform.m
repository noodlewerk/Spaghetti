//
//  NWSTimeStampTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTimeStampTransform.h"
#import "NWAbout.h"
#import "NWSMappingContext.h"


@implementation NWSTimeStampTransform


#pragma mark - Object life cycle

+ (NWSTimeStampTransform *)shared
{
    static NWSTimeStampTransform *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSTimeStampTransform alloc] init];
    });
    return result;
}


#pragma mark - NWSTransform

- (NSDate *)transform:(NSNumber *)number context:(NWSMappingContext *)context
{
    if ([number isKindOfClass:NSNumber.class]) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } else {
        NWLogWarn(@"Expecting NSString instead of %@ (path:%@)", number.class, context.path);
        return nil;
    }
}

- (NSNumber *)reverse:(NSDate *)date context:(NWSMappingContext *)context
{
    if ([date isKindOfClass:NSDate.class]) {
        return @([date timeIntervalSince1970]);
    } else {
        NWLogWarn(@"Expecting NSDate instead of %@ (path:%@)", date.class, context.path);
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"timestamp transform" about:prefix];
}

@end
