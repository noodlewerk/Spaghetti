//
//  NWSJSONParser.m
//  NWService
//
//  Created by leonard on 5/9/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSJSONParser.h"


@implementation NWSJSONParser

- (id)parse:(NSData *)data
{
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NWLogWarnIfError(error);
    return result;
}

- (NSData *)serialize:(id)value
{
    NSError *error = nil;
    NSData *result = [NSJSONSerialization dataWithJSONObject:value options:0 error:&error];
    NWLogWarnIfError(error);
    return result;
}

+ (id)shared
{
    static NWSJSONParser *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSJSONParser alloc] init];
    });
    return result;
}

@end
