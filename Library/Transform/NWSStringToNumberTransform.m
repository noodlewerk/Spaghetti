//
//  NWSStringToNumberTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSStringToNumberTransform.h"
#import "NWAbout.h"
#import "NWSMappingContext.h"


@implementation NWSStringToNumberTransform


#pragma mark - Object life cycle

+ (NWSStringToNumberTransform *)shared
{
    static NWSStringToNumberTransform *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSStringToNumberTransform alloc] init];
    });
    return result;
}


#pragma mark - NWSTransform

- (id)transform:(NSString *)string context:(NWSMappingContext *)context
{
    if ([string isKindOfClass:NSString.class]) {
        return [self.class numberForString:string];
    } else if (string) {
        NWLogWarn(@"Expecting NSString instead of %@ (path:%@)", string.class, context.path);
    }
    return nil;
}

- (id)reverse:(NSNumber *)number context:(NWSMappingContext *)context
{
    if ([number isKindOfClass:NSNumber.class]) {
        return [number stringValue];
    } else if (number) {
        NWLogWarn(@"Expecting NSNumber instead of %@ (path:%@)", number.class, context.path);
    }
    return nil;
}


#pragma mark - String to Number

+ (BOOL)isZeroString:(NSString *)string
{
    NSUInteger i = 0, length = string.length;
    if (i == length) return NO;
    if ([string characterAtIndex:i] == '+' || [string characterAtIndex:i] == '-') i++;
    if (i == length) return NO;
    while (i < length && [string characterAtIndex:i] == '0') i++;
    if (i == length) return YES;
    if ([string characterAtIndex:i] == '.') i++;
    if (i == length) return YES;
    while (i < length && [string characterAtIndex:i] == '0') i++;
    return i == string.length;
}

+ (NSNumber *)numberForString:(NSString *)string
{
    if (!string.length) {
        return nil;
    }
    if ([string isEqualToString:@"true"] || [string isEqualToString:@"YES"]) {
        return @YES;
    }
    if ([string isEqualToString:@"false"] || [string isEqualToString:@"NO"]) {
        return @NO;
    }
    if ([string rangeOfString:@"e"].length || [string rangeOfString:@"E"].length) {
        NSRange r = [string rangeOfString:@"e"];
        if (!r.length) r = [string rangeOfString:@"E"];
        NSString *coe = [string substringToIndex:r.location];
        double c = [coe doubleValue];
        if (c || [self isZeroString:coe]) {
            NSString *exp = [string substringFromIndex:r.location + r.length];
            int e = [exp intValue];
            if (e || [self isZeroString:exp]) {
                double d = c * pow(10, e);
                return @(d);
            }
        }
        return nil;
    }
    if ([string rangeOfString:@"."].length) {
        double d = [string doubleValue];
        if (d || [self isZeroString:string]) {
            return @(d);
        }
    } else {
        long long i = [string longLongValue];
        if (i || [self isZeroString:string]) {
            return @(i);
        }
    }
    return nil;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"string-to-number" about:prefix];
}

@end
