//
//  NWSCommon.m
//  NWService
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

- (NSNumber *)number
{
    if (!self.length) {
        return nil;
    }
    if ([self isEqualToString:@"true"] || [self isEqualToString:@"YES"]) {
        return [NSNumber numberWithBool:YES];
    }
    if ([self isEqualToString:@"false"] || [self isEqualToString:@"NO"]) {
        return [NSNumber numberWithBool:NO];
    }
    if ([self rangeOfString:@"e"].length || [self rangeOfString:@"E"].length) {
        // TODO
        return nil;
    }
    if ([self rangeOfString:@"."].length) {
        double d = [self doubleValue];
        if (d || [self isEqualToString:@"0"] || [self isEqualToString:@".0"] || [self isEqualToString:@"0."] || [self isEqualToString:@"0.0"]) {
            return [NSNumber numberWithDouble:d];
        }
    } else if ([self rangeOfString:@"."].length) {
        int i = [self intValue];
        if (i || [self isEqualToString:@"0"] || [self isEqualToString:@"00"]) {
            return [NSNumber numberWithInt:[self intValue]];
        }
    }
    return nil;
}

@end
