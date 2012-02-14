//
//  NWSCommonTest.m
//  NWService
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

@end
