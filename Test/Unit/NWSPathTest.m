//
//  NWSPathTest.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NWSPath.h"


@interface NWSPathTest : SenTestCase
@end

@implementation NWSPathTest {
    NSMutableDictionary *dictionary;
    NSMutableArray *array;
}

- (void)setUp
{
    NWLBreakWarn();
    dictionary = [[NSMutableDictionary alloc] init];
    array = [[NSMutableArray alloc] init];
    
    [dictionary setObject:@"string-1" forKey:@"string"];
    [dictionary setObject:[NSNumber numberWithInteger:1] forKey:@"integer"];
    [dictionary setObject:NSNull.null forKey:@"null"];
    [dictionary setObject:dictionary forKey:@"dictionary"];
    [dictionary setObject:array forKey:@"array"];

    [array addObject:@"string-2"];
    [array addObject:[NSNumber numberWithInteger:2]];
    [array addObject:NSNull.null];
    [array addObject:dictionary];
    [array addObject:array];
}

- (void)testSingle
{
    STAssertTrue([[dictionary valueForPathString:@"string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[dictionary valueForPathString:@"integer"] integerValue] == 1, @"");
    STAssertTrue([dictionary valueForPathString:@"null"] == NSNull.null, @"");
    STAssertTrue([[dictionary valueForPathString:@"array"] isKindOfClass:NSArray.class], @"");
    STAssertTrue([[dictionary valueForPathString:@"dictionary"] isKindOfClass:NSDictionary.class], @"");

    [dictionary setValue:@"string-0" forPathString:@"string"];
    STAssertTrue([[dictionary valueForPathString:@"string"] isEqualToString:@"string-0"], @"");
}

- (void)testKeyPath
{
    STAssertTrue([[dictionary valueForPathString:@"dictionary.string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[dictionary valueForPathString:@"dictionary.integer"] integerValue] == 1, @"");
    STAssertTrue([dictionary valueForPathString:@"dictionary.null"] == NSNull.null, @"");
    STAssertTrue([[dictionary valueForPathString:@"dictionary.array"] isKindOfClass:NSArray.class], @"");
    STAssertTrue([[dictionary valueForPathString:@"dictionary.dictionary"] isKindOfClass:NSDictionary.class], @"");
    
    STAssertTrue([[dictionary valueForPathString:@"dictionary.dictionary.string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[dictionary valueForPathString:@"dictionary.dictionary.integer"] integerValue] == 1, @"");
    STAssertTrue([dictionary valueForPathString:@"dictionary.dictionary.null"] == NSNull.null, @"");
    STAssertTrue([[dictionary valueForPathString:@"dictionary.dictionary.array"] isKindOfClass:NSArray.class], @"");
    STAssertTrue([[dictionary valueForPathString:@"dictionary.dictionary.dictionary"] isKindOfClass:NSDictionary.class], @"");
    
    [dictionary setValue:@"string-0" forPathString:@"dictionary.dictionary.string"];
    STAssertTrue([[dictionary valueForPathString:@"dictionary.dictionary.string"] isEqualToString:@"string-0"], @"");
}

- (void)testConstantValue
{
    STAssertTrue([[dictionary valueForPathString:@"=string:"] isEqualToString:@""], @"");
    STAssertTrue([[dictionary valueForPathString:@"=string:string"] isEqualToString:@"string"], @"");
    STAssertTrue([[dictionary valueForPathString:@"=bool:true"] boolValue] == true, @"");
    STAssertTrue([[dictionary valueForPathString:@"=int:3"] intValue] == 3, @"");
    STAssertTrue([[dictionary valueForPathString:@"=integer:33"] integerValue] == 33, @"");
    STAssertTrue([[dictionary valueForPathString:@"=float:3.3"] floatValue] == 3.3f, @"");
    STAssertTrue([[dictionary valueForPathString:@"=double:3000000000000000.3"] doubleValue] == 3000000000000000.3, @"");
    STAssertTrue([[dictionary valueForPathString:@"=longlong:3000000000000000"] longLongValue] == 3000000000000000, @"");
    STAssertTrue([dictionary valueForPathString:@"=nil:xx"] == nil, @"");
    STAssertTrue([dictionary valueForPathString:@"=null:"] == NSNull.null, @"");
    
    STAssertTrue([[dictionary valueForPathString:@"=:"] isEqualToString:@""], @"");
    STAssertTrue([[dictionary valueForPathString:@"=:string"] isEqualToString:@"string"], @"");
    STAssertTrue([[dictionary valueForPathString:@"="] isEqualToString:@""], @"");
    STAssertTrue([[dictionary valueForPathString:@"=string"] isEqualToString:@"string"], @"");
    STAssertTrue([[dictionary valueForPathString:@"=1"] integerValue] == 1, @"");
    STAssertTrue([[dictionary valueForPathString:@"=1.1"] doubleValue] == 1.1, @"");

    [dictionary setValue:@"string-0" forPathString:@"=string:"];
    STAssertTrue([[dictionary valueForPathString:@"=string:"] isEqualToString:@""], @"");
}

- (void)testComposite
{
    STAssertTrue([[dictionary valueForPathString:@":string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[dictionary valueForPathString:@":integer"] integerValue] == 1, @"");
    STAssertTrue([dictionary valueForPathString:@":null"] == NSNull.null, @"");
    STAssertTrue([[dictionary valueForPathString:@":dictionary:string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[dictionary valueForPathString:@":dictionary:integer"] integerValue] == 1, @"");
    STAssertTrue([[dictionary valueForPathString:@":array:0"] isEqualToString:@"string-2"], @"");
    STAssertTrue([[dictionary valueForPathString:@":array:1"] integerValue] == 2, @"");
    STAssertTrue([[dictionary valueForPathString:@":array:-5"] isEqualToString:@"string-2"], @"");
    STAssertTrue([[dictionary valueForPathString:@":array:-4"] integerValue] == 2, @"");
    STAssertTrue([[dictionary valueForPathString:@":array:-2:string"] isEqualToString:@"string-1"], @"");
    
    [dictionary setValue:@"string-0" forPathString:@":array:-2:string"];
    STAssertTrue([[dictionary valueForPathString:@":array:-2:string"] isEqualToString:@"string-0"], @"");
}

@end
