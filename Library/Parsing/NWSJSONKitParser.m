//
//  NWSJSONKitParser.m
//  NWService
//
//  Created by leonard on 5/9/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSJSONKitParser.h"
#import "JSONKit.h"


@implementation NWSJSONKitParser

- (id)parse:(NSData *)data
{
    NSError *error = nil;
    id result = [data objectFromJSONDataWithParseOptions:JKParseOptionStrict error:&error];
    NWLogWarnIfError(error);
    return result;
}

- (NSData *)serialize:(id)value
{
    NSError *error = nil;
    NSData *result = [value JSONDataWithOptions:JKSerializeOptionNone error:&error];
    NWLogWarnIfError(error);
    return result;
}

+ (id)shared
{
    static NWSJSONKitParser *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSJSONKitParser alloc] init];
    });
    return result;
}

@end
