//
//  NWSObjectID.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSObjectID.h"
#import "NWAbout.h"
#include "NWLCore.h"


@implementation NWSObjectID


#pragma mark - Object life cycle

- (BOOL)isEqual:(NWSObjectID *)identifier // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return NO;
} // COV_NF_END

- (NSUInteger)hash // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return NO;
} // COV_NF_END


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"object-id" about:prefix];
}

@end
