//
//  NWSMappingTest.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NWAbout.h"
#import "NWSMapping.h"
#import "NWSMappingContext.h"
#import "NWSMappingValidator.h"
#import "NWSPolicy.h"


@interface NWSMappingTest : SenTestCase
@end

@implementation NWSMappingTest

- (void)setUp
{
    NWSLBreakWarn();
}

- (void)testMapping
{
    NWSMapping *i = [[NWSMapping alloc] init];
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

- (void)testMappingContext
{
    NWSMappingContext *i = [[NWSMappingContext alloc] init];
    STAssertNotNil(i.path, @"");
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

- (void)testMappingEntry
{
    NWSMappingEntry *i = [[NWSMappingEntry alloc] init];
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

- (void)testMappingValidator
{
    NWSMappingValidator *i = [[NWSMappingValidator alloc] init];
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

- (void)testSetterPolicy
{
    NWSPolicy *i = NWSPolicy.appendMany;
    STAssertNotNil([NWSPolicy.replaceOne description], @"");
    STAssertNotNil([NWSPolicy.replaceMany description], @"");
    STAssertNotNil([NWSPolicy.deleteOne description], @"");
    STAssertNotNil([NWSPolicy.deleteMany description], @"");
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

@end
