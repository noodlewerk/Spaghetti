//
//  NWSCommon.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSCommon.h"


@implementation NSObject (NWSCommon)

- (NSString *)readable
{
    return [self readable:@""];
}

- (NSString *)readable:(NSString *)prefix
{
    return [self description];
}

- (id)mapWithBlock:(id(^)(id))block
{
    if (![self isKindOfClass:NSArray.class]) {
        return block(self);
    }
    NSArray *objects = (NSArray *)self;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (id object in objects) {
        id mapped = [object mapWithBlock:block];
        if (mapped) {
            [result addObject:mapped];
        } else {
            [result addObject:NSNull.null];
        }
    }
    return result;
}

@end


static const NSUInteger NWSMaxReadableArrayLength = 24;

@implementation NSArray (NWSCommon)
- (NSString *)readable:(NSString *)prefix
{
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"["];
    for (id i in self) {
        [result appendFormat:@"%@ ", [i readable:prefix]];
        if (result.length > NWSMaxReadableArrayLength - 1) {
            NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"[\n"];
            NSString *p = [prefix stringByAppendingString:@"   "];
            for (id i in self) {
                [result appendFormat:@"%@%@\n", p, [i readable:p]];
            }
            [result appendFormat:@"%@]", prefix];
            return result;
        }
    }
    [result appendString:@"]"];
    return result;
}

@end



@implementation NSString (NWSCommon)

- (BOOL)isZero
{
    NSUInteger i = 0, length = self.length;
    if (i == length) return NO;
    if ([self characterAtIndex:i] == '+' || [self characterAtIndex:i] == '-') i++;
    if (i == length) return NO;
    while (i < length && [self characterAtIndex:i] == '0') i++;
    if (i == length) return YES;
    if ([self characterAtIndex:i] == '.') i++;
    if (i == length) return YES;
    while (i < length && [self characterAtIndex:i] == '0') i++;
    return i == self.length;
}

- (NSNumber *)number
{
    if (!self.length) {
        return nil;
    }
    if ([self isEqualToString:@"true"] || [self isEqualToString:@"YES"]) {
        return @YES;
    }
    if ([self isEqualToString:@"false"] || [self isEqualToString:@"NO"]) {
        return @NO;
    }
    if ([self rangeOfString:@"e"].length || [self rangeOfString:@"E"].length) {
        NSRange r = [self rangeOfString:@"e"];
        if (!r.length) r = [self rangeOfString:@"E"];
        NSString *coe = [self substringToIndex:r.location];
        double c = [coe doubleValue];
        if (c || [coe isZero]) {
            NSString *exp = [self substringFromIndex:r.location + r.length];
            int e = [exp intValue];
            if (e || [exp isZero]) {
                double d = c * pow(10, e);
                return @(d);
            }
        }
        return nil;
    }
    if ([self rangeOfString:@"."].length) {
        double d = [self doubleValue];
        if (d || [self isZero]) {
            return @(d);
        }
    } else {
        long long i = [self longLongValue];
        if (i || [self isZero]) {
            return @(i);
        }
    }
    return nil;
}

@end
