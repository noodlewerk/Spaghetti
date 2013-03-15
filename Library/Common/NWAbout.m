//
//  NWAbout.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWAbout.h"


@implementation NSObject (NWAbout)

- (NSString *)about
{
    return [self about:@""];
}

- (NSString *)about:(NSString *)prefix
{
    return [self description];
}

@end


static const NSUInteger NWSMaxAboutArrayLength = 24;

@implementation NSArray (NWAbout)

- (NSString *)about:(NSString *)prefix
{
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"["];
    for (id i in self) {
        [result appendFormat:@"%@ ", [i about:prefix]];
        if (result.length > NWSMaxAboutArrayLength - 1) {
            NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"[\n"];
            NSString *p = [prefix stringByAppendingString:@"   "];
            for (id i in self) {
                [result appendFormat:@"%@%@\n", p, [i about:p]];
            }
            [result appendFormat:@"%@]", prefix];
            return result;
        }
    }
    [result appendString:@"]"];
    return result;
}

@end
