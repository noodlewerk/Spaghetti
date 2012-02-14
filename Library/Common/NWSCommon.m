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
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    NSNumber *result = [formatter numberFromString:self];
    return result;
}

@end
