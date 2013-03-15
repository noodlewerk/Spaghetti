//
//  NWSObjectType.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSObjectType.h"
#import "NWAbout.h"
#import "NWSPath.h"


@implementation NWSObjectType


#pragma mark - Object Type

- (BOOL)matches:(NSObject *)object // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return NO;
} // COV_NF_END

+ (BOOL)supports:(NSObject *)object // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return NO;
} // COV_NF_END

- (BOOL)hasAttribute:(NWSPath *)attribute // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return NO;
} // COV_NF_END

- (BOOL)hasRelation:(NWSPath *)relation toMany:(BOOL)toMany // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return NO;
} // COV_NF_END

- (BOOL)isEqual:(NWSObjectType *)type // COV_NF_START
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
    return [@"object-type" about:prefix];
}

@end
