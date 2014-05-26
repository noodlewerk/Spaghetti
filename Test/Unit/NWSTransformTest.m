//
//  NWSTransformTest.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NWSStringToNumberTransform.h"
#import "NWStats.h"


@interface NWAboutTest : SenTestCase
@end

@implementation NWAboutTest

- (void)setUp
{
    NWSLBreakWarn();
}

- (void)testStats
{
    NWStats *i = [[NWStats alloc] init];
    [i count:1];
    
    STAssertTrue(i.average == 1, @"");
    STAssertTrue(i.variance == 0, @"");
    STAssertTrue(i.deviation == 0, @"");
    STAssertNotNil(i.description, @"");
}

- (void)testStringToNumber
{
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0"], @0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"1"], @1, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"-2"], @-2, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"200"], @200, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"200000000000"], @200000000000, @"");
    
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0.0"], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0.1"], @0.1, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"-0.2"], @-0.2, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0.002"], @0.002, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0.000000000002"], @0.000000000002, @"");

    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0e0"], @0e0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0e7"], @0e7, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"1e0"], @1e0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"1e7"], @1e7, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"1.e7"], @1.e7, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@".1e7"], @.1e7, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0.0000000002e7"], @0.0000000002e7, @"");

    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@""], nil, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@" "], nil, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@".."], nil, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"e"], nil, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@".e"], nil, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"e."], nil, @"");

    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"00"], @0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0."], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@".0"], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"0.0"], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"."], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"-0"], @0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"-0."], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"+.0"], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"+0.0"], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"-000.000"], @0.0, @"");
    STAssertEqualObjects([NWSStringToNumberTransform numberForString:@"+000.000"], @0.0, @"");
}

@end
