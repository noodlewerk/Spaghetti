//
//  NWSStringParser.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSStringParser.h"

@implementation NWSStringParser

- (id)parse:(NSData *)data
{
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NWLogWarnIfNot(result.length, @"Parser result empty");
    return result;
}

- (NSData *)serialize:(NSString *)value
{
    NSData *result = [value dataUsingEncoding:NSUTF8StringEncoding];
    NWLogWarnIfNot(result.length, @"Parser result empty");
    return result;
}

+ (id)shared
{
    static NWSStringParser *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSStringParser alloc] init];
    });
    return result;
}

@end
