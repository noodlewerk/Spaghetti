//
//  NWSURLParser.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSURLParser.h"
#import "NWHTTP.h"


@implementation NWSURLParser

- (NSDictionary *)parse:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [NWHTTP splitQueryWithString:string];
}

- (NSData *)serialize:(NSDictionary *)dictionary
{
    if (_multipartBoundary) {
        NSString *boundary = _multipartBoundary;
        return [NWHTTP multipartDataWithParameters:dictionary boundary:&boundary];
    }
    NSString *query = [NWHTTP joinQueryWithDictionary:dictionary];
    return [query dataUsingEncoding:NSUTF8StringEncoding];
}

+ (id)shared
{
    static NWSURLParser *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSURLParser alloc] init];
    });
    return result;
}

+ (NSString *)generateHexBoundary:(NSUInteger)length
{
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:length];
    while (length--) [result appendFormat:@"%c", "0123456789ABCDEF"[arc4random() % 16]];
    return result;
}

@end
