//
//  NWSCommonTest.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NWSCommon.h"
#import "NWSVarStat.h"


@interface NWSCommonTest : SenTestCase
@end

@implementation NWSCommonTest

- (void)setUp
{
    NWLBreakWarn();
}

- (void)testReadable
{
    NSArray *i = [NSArray arrayWithObject:@"                                  "];
    STAssertNotNil(i.readable, @"");
}

- (void)testVarStat
{
    NWSVarStat *i = [[NWSVarStat alloc] init];
    [i count:1];
    
    STAssertTrue(i.average == 1, @"");
    STAssertTrue(i.variance == 0, @"");
    STAssertTrue(i.deviation == 0, @"");
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.readable, @"");
}

- (void)testStringToNumber
{
    STAssertEqualObjects([@"0" number], @0, @"");
    STAssertEqualObjects([@"1" number], @1, @"");
    STAssertEqualObjects([@"-2" number], @-2, @"");
    STAssertEqualObjects([@"200" number], @200, @"");
    STAssertEqualObjects([@"200000000000" number], @200000000000, @"");
    
    STAssertEqualObjects([@"0.0" number], @0.0, @"");
    STAssertEqualObjects([@"0.1" number], @0.1, @"");
    STAssertEqualObjects([@"-0.2" number], @-0.2, @"");
    STAssertEqualObjects([@"0.002" number], @0.002, @"");
    STAssertEqualObjects([@"0.000000000002" number], @0.000000000002, @"");

    STAssertEqualObjects([@"0e0" number], @0e0, @"");
    STAssertEqualObjects([@"0e7" number], @0e7, @"");
    STAssertEqualObjects([@"1e0" number], @1e0, @"");
    STAssertEqualObjects([@"1e7" number], @1e7, @"");
    STAssertEqualObjects([@"1.e7" number], @1.e7, @"");
    STAssertEqualObjects([@".1e7" number], @.1e7, @"");
    STAssertEqualObjects([@"0.0000000002e7" number], @0.0000000002e7, @"");

    STAssertEqualObjects([@"" number], nil, @"");
    STAssertEqualObjects([@" " number], nil, @"");
    STAssertEqualObjects([@".." number], nil, @"");
    STAssertEqualObjects([@"e" number], nil, @"");
    STAssertEqualObjects([@".e" number], nil, @"");
    STAssertEqualObjects([@"e." number], nil, @"");

    STAssertEqualObjects([@"00" number], @0, @"");
    STAssertEqualObjects([@"0." number], @0.0, @"");
    STAssertEqualObjects([@".0" number], @0.0, @"");
    STAssertEqualObjects([@"0.0" number], @0.0, @"");
    STAssertEqualObjects([@"." number], @0.0, @"");
    STAssertEqualObjects([@"-0" number], @0, @"");
    STAssertEqualObjects([@"-0." number], @0.0, @"");
    STAssertEqualObjects([@"+.0" number], @0.0, @"");
    STAssertEqualObjects([@"+0.0" number], @0.0, @"");
    STAssertEqualObjects([@"-000.000" number], @0.0, @"");
    STAssertEqualObjects([@"+000.000" number], @0.0, @"");

}

@end
