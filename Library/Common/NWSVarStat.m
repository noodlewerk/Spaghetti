//
//  NWSVarStat.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSVarStat.h"
#import "NWSCommon.h"


@implementation NWSVarStat {
    long double sum;
    long double squareSum;
}

@synthesize count;

- (void)count:(double)value
{
    count++;
    sum += value;
    squareSum += (long double)value * value;
}

- (double)average
{
    if (count) {
        return (double)(sum / count);
    } else {
        return .0;
    }
}

- (long double)variance
{
    if (count) {
        return (squareSum - sum / count * sum) / count;
    } else {
        return .0;
    }
}

- (double)deviation
{
    return (double)sqrtl(self.variance);
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p count:%u sum:%f>", NSStringFromClass(self.class), self, count, (double)sum];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"%f±%f (#%u)", self.average, self.deviation, count] readable:prefix];
}

@end
