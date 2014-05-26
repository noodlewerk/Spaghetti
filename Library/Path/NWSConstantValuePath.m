//
//  NWSConstantValuePath.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSConstantValuePath.h"
#import "NWSStringToNumberTransform.h"
#import "NWAbout.h"
//#include "NWSLCore.h"


@implementation NWSConstantValuePath


#pragma mark - Object life cycle

- (id)initWithValue:(id)value
{
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (BOOL)isEqual:(NWSConstantValuePath *)path
{
    return self == path || (self.class == path.class && [self.value isEqual:path.value]);
}

- (NSUInteger)hash
{
    return 6770730819 + [_value hash];
}


#pragma mark - Path

- (id)valueWithObject:(NSObject *)object
{
    return _value;
}

- (void)setWithObject:(NSObject *)object value:(id)value
{
    // can't set constant, can I?
}


#pragma mark - String parsing

+ (NWSConstantValuePath *)pathFromString:(NSString *)string
{
    NSRange r = [string rangeOfString:@":"];
    if (!r.length) {
        r.location = 0;
    }
    NSString *type = [string substringToIndex:r.location];
    NSString *value = [string substringFromIndex:r.location + r.length];
    if (!type.length) {
        NSNumber *number = [NWSStringToNumberTransform numberForString:value];
        return [[NWSConstantValuePath alloc] initWithValue:number ? number : value];
    } else if ([type isEqualToString:@"nil"]) {
        return [[NWSConstantValuePath alloc] initWithValue:nil];
    } else if ([type isEqualToString:@"null"]) {
        return [[NWSConstantValuePath alloc] initWithValue:NSNull.null];
    } else if ([type isEqualToString:@"string"]) {
        return [[NWSConstantValuePath alloc] initWithValue:value];
    } else if ([type isEqualToString:@"int"]) {
        return [[NWSConstantValuePath alloc] initWithValue:@([value intValue])];
    } else if ([type isEqualToString:@"bool"]) {
        return [[NWSConstantValuePath alloc] initWithValue:@([value boolValue])];
    } else if ([type isEqualToString:@"integer"]) {
        return [[NWSConstantValuePath alloc] initWithValue:@([value integerValue])];
    } else if ([type isEqualToString:@"longlong"]) {
        return [[NWSConstantValuePath alloc] initWithValue:@([value longLongValue])];
    } else if ([type isEqualToString:@"float"]) {
        return [[NWSConstantValuePath alloc] initWithValue:@([value floatValue])];
    } else if ([type isEqualToString:@"double"]) {
        return [[NWSConstantValuePath alloc] initWithValue:@([value doubleValue])];
    }
    NWSLogWarn(@"Unknown type in parsing constant path: %@", type);
    return nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p key:%@>", NSStringFromClass(self.class), self, _value];
}

- (NSString *)about:(NSString *)prefix
{
    return [_value about:prefix];
}

@end
