//
//  NWSObjectID.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSObjectID.h"
#import "NWSCommon.h"


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

- (NSString *)readable:(NSString *)prefix
{
    return [@"object-id" readable:prefix];
}

@end
