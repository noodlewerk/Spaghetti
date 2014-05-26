//
//  NWSHTTPTest.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NWAbout.h"
#import "NWSHTTPCall.h"
#import "NWHTTPConnection.h"
#import "NWSHTTPDialogue.h"
#import "NWSHTTPEndpoint.h"


@interface NWSHTTPTest : SenTestCase
@end

@implementation NWSHTTPTest

- (void)setUp
{
    NWSLPrintWarn();
}

- (void)testHTTPCall
{
    NWSHTTPCall *i = [[NWSHTTPCall alloc] init];
    i.urlString = @"";
    [i setHeaderValue:@"" forKey:@""];
    [i setHeaders:@{}];
    
    STAssertNotNil(i.resolvedURL, @"");
    STAssertNotNil(i.newDialogue, @"");
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

- (void)testHTTPConnection
{
    NWHTTPConnection *i = [[NWHTTPConnection alloc] init];
    
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

- (void)testHTTPDialogue
{
    NWSHTTPDialogue *i = [[NWSHTTPDialogue alloc] init];
    
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

- (void)testHTTPEndpoint
{
    NWSHTTPEndpoint *i = [[NWSHTTPEndpoint alloc] init];
    
    STAssertNotNil([i newCall], @"");
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.about, @"");
}

- (void)testDereferencing
{
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    
    STAssertEqualObjects([NWSCall dereference:@"" parameters:d], @"", @"");
    STAssertEqualObjects([NWSCall dereference:@"a" parameters:d], @"a", @"");
    STAssertEqualObjects([NWSCall dereference:@"$()" parameters:d], @"?()", @"");
    STAssertEqualObjects([NWSCall dereference:@"%()" parameters:d], @"?()", @"");
    STAssertEqualObjects([NWSCall dereference:@"$(a)" parameters:d], @"?(a)", @"");
    STAssertEqualObjects([NWSCall dereference:@"%(a)" parameters:d], @"?(a)", @"");
    d[@""] = @"";
    STAssertEqualObjects([NWSCall dereference:@"$()" parameters:d], @"", @"");
    STAssertEqualObjects([NWSCall dereference:@"%()" parameters:d], @"", @"");
    d[@""] = @".";
    STAssertEqualObjects([NWSCall dereference:@"$()" parameters:d], @".", @"");
    STAssertEqualObjects([NWSCall dereference:@"%()" parameters:d], @".", @"");
    d[@"a"] = @"a.";
    STAssertEqualObjects([NWSCall dereference:@"$(a)" parameters:d], @"a.", @"");
    STAssertEqualObjects([NWSCall dereference:@"%(a)" parameters:d], @"a.", @"");
    d[@"a"] = @"";
    STAssertEqualObjects([NWSCall dereference:@"x$(a)" parameters:d], @"x", @"");
    STAssertEqualObjects([NWSCall dereference:@"$(a)y" parameters:d], @"y", @"");
    STAssertEqualObjects([NWSCall dereference:@"x$(a)y" parameters:d], @"xy", @"");
    d[@"aa"] = @"aa.";
    STAssertEqualObjects([NWSCall dereference:@"$(aa)" parameters:d], @"aa.", @"");
    STAssertEqualObjects([NWSCall dereference:@"%(aa)" parameters:d], @"aa.", @"");
    d[@"a"] = @"±!@#$%^&*()_+z";
    STAssertEqualObjects([NWSCall dereference:@"$(a)" parameters:d], @"±!@#$%^&*()_+z", @"");
    STAssertEqualObjects([NWSCall dereference:@"%(a)" parameters:d], @"%C2%B1%21%40%23%24%25%5E%26%2A%28%29_%2Bz", @"");
    STAssertEqualObjects([NWSCall dereference:@"*$(a)*%(a)*" parameters:d], @"*±!@#$%^&*()_+z*%C2%B1%21%40%23%24%25%5E%26%2A%28%29_%2Bz*", @"");
}

@end
