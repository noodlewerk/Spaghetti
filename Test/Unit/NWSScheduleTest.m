//
//  NWSScheduleTest.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Spaghetti.h"


@interface NWSScheduleTest : SenTestCase
@end

@implementation NWSScheduleTest

- (void)setUp
{
    NWLBreakWarn();
}

- (void)test
{
    return; // slow test
    
    NWLPrintDbugInFile("NWSSchedule.m");
    NWLPrintDbugInFile("NWSScheduleTest.m");
    
    NWSSchedule *schedule = [[NWSSchedule alloc] init];
    [schedule start];
    NWLResetPrintClock();
    
    [schedule addCall:[[NWSTestCall alloc] init]];
    [schedule addCall:[[NWSTestCall alloc] init] afterDelay:2];
    [schedule addCall:[[NWSTestCall alloc] init] repeatInterval:3];
    [schedule addCall:[[NWSTestCall alloc] init] onDate:[NSDate dateWithTimeInterval:6 sinceDate:NSDate.date]];
    
    for (NSUInteger i = 0; i < 10; i++) {
        NSDate *d = [NSDate dateWithTimeIntervalSinceNow:1];
        [NSRunLoop.mainRunLoop runMode:NSDefaultRunLoopMode beforeDate:d];
        NSUInteger count = schedule.count;
        STAssertTrue(i < 0 || i > 2 || count == 3, @"");
        STAssertTrue(i < 3 || i > 5 || count == 2, @"");
        STAssertTrue(i < 6 || i > 9 || count == 1, @"");
    }
    [schedule cancel];
}

@end
