//
//  NWStats.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWStats.h"
#import "NWSCommon.h"


@implementation NWStats {
    long double _sum;
    long double _squareSum;
}

- (void)count:(double)value
{
    _count++;
    _sum += value;
    _squareSum += (long double)value * value;
}

- (double)average
{
    if (_count) {
        return (double)(_sum / _count);
    } else {
        return .0;
    }
}

- (long double)variance
{
    if (_count) {
        return (_squareSum - _sum / _count * _sum) / _count;
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
    return [NSString stringWithFormat:@"<%@:%p count:%lu sum:%f>", NSStringFromClass(self.class), self, _count, (double)_sum];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"%f±%f (#%lu)", self.average, self.deviation, _count] readable:prefix];
}

@end
