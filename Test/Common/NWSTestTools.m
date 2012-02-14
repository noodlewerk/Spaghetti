//
//  NWSTestTools.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTestTools.h"
#import "JSONKit.h"


@implementation NWSTestTools

+ (NSString *)jsonForSQON:(NSString *)singlyQuotedObjectNotation
{
    NSString *result = singlyQuotedObjectNotation;
    result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    result = [result stringByReplacingOccurrencesOfString:@"{" withString:@"{\""];
    result = [result stringByReplacingOccurrencesOfString:@":" withString:@"\":"];
    result = [result stringByReplacingOccurrencesOfString:@"," withString:@",\""];
    result = [result stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    return result;
}

+ (id)objectForSQON:(NSString *)singlyQuotedObjectNotation
{
    NSString *json = [self jsonForSQON:singlyQuotedObjectNotation];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionStrict];
    NSError *error = nil;
    id result = [decoder objectWithData:data error:&error];
    NWLogWarnIfError(error);
    return result;
}


@end
