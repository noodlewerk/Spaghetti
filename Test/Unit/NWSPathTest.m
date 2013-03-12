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
    NSMutableDictionary *_dictionary;
    NSMutableArray *_array;
}

- (void)setUp
{
    NWLBreakWarn();
    _dictionary = [[NSMutableDictionary alloc] init];
    _array = [[NSMutableArray alloc] init];
    
    _dictionary[@"string"] = @"string-1";
    _dictionary[@"integer"] = @1;
    _dictionary[@"null"] = NSNull.null;
    _dictionary[@"dictionary"] = _dictionary;
    _dictionary[@"array"] = _array;

    [_array addObject:@"string-2"];
    [_array addObject:@2];
    [_array addObject:NSNull.null];
    [_array addObject:_dictionary];
    [_array addObject:_array];
}

- (void)testSingle
{
    STAssertTrue([[_dictionary valueForPathString:@"string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[_dictionary valueForPathString:@"integer"] integerValue] == 1, @"");
    STAssertTrue([_dictionary valueForPathString:@"null"] == NSNull.null, @"");
    STAssertTrue([[_dictionary valueForPathString:@"array"] isKindOfClass:NSArray.class], @"");
    STAssertTrue([[_dictionary valueForPathString:@"dictionary"] isKindOfClass:NSDictionary.class], @"");

    [_dictionary setValue:@"string-0" forPathString:@"string"];
    STAssertTrue([[_dictionary valueForPathString:@"string"] isEqualToString:@"string-0"], @"");
}

- (void)testKeyPath
{
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.integer"] integerValue] == 1, @"");
    STAssertTrue([_dictionary valueForPathString:@"dictionary.null"] == NSNull.null, @"");
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.array"] isKindOfClass:NSArray.class], @"");
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.dictionary"] isKindOfClass:NSDictionary.class], @"");
    
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.dictionary.string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.dictionary.integer"] integerValue] == 1, @"");
    STAssertTrue([_dictionary valueForPathString:@"dictionary.dictionary.null"] == NSNull.null, @"");
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.dictionary.array"] isKindOfClass:NSArray.class], @"");
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.dictionary.dictionary"] isKindOfClass:NSDictionary.class], @"");
    
    [_dictionary setValue:@"string-0" forPathString:@"dictionary.dictionary.string"];
    STAssertTrue([[_dictionary valueForPathString:@"dictionary.dictionary.string"] isEqualToString:@"string-0"], @"");
}

- (void)testConstantValue
{
    STAssertTrue([[_dictionary valueForPathString:@"=string:"] isEqualToString:@""], @"");
    STAssertTrue([[_dictionary valueForPathString:@"=string:string"] isEqualToString:@"string"], @"");
    STAssertTrue([[_dictionary valueForPathString:@"=bool:true"] boolValue] == true, @"");
    STAssertTrue([[_dictionary valueForPathString:@"=int:3"] intValue] == 3, @"");
    STAssertTrue([[_dictionary valueForPathString:@"=integer:33"] integerValue] == 33, @"");
    STAssertTrue([[_dictionary valueForPathString:@"=float:3.3"] floatValue] == 3.3f, @"");
    STAssertTrue([[_dictionary valueForPathString:@"=double:3000000000000000.3"] doubleValue] == 3000000000000000.3, @"");
    STAssertTrue([[_dictionary valueForPathString:@"=longlong:3000000000000000"] longLongValue] == 3000000000000000, @"");
    STAssertTrue([_dictionary valueForPathString:@"=nil:xx"] == nil, @"");
    STAssertTrue([_dictionary valueForPathString:@"=null:"] == NSNull.null, @"");
    
    STAssertTrue([[_dictionary valueForPathString:@"=:"] isEqualToString:@""], @"");
    STAssertTrue([[_dictionary valueForPathString:@"=:string"] isEqualToString:@"string"], @"");
    STAssertTrue([[_dictionary valueForPathString:@"="] isEqualToString:@""], @"");
    STAssertTrue([[_dictionary valueForPathString:@"=string"] isEqualToString:@"string"], @"");
    STAssertTrue([[_dictionary valueForPathString:@"=1"] integerValue] == 1, @"");
    STAssertTrue([[_dictionary valueForPathString:@"=1.1"] doubleValue] == 1.1, @"");

    [_dictionary setValue:@"string-0" forPathString:@"=string:"];
    STAssertTrue([[_dictionary valueForPathString:@"=string:"] isEqualToString:@""], @"");
}

- (void)testComposite
{
    STAssertTrue([[_dictionary valueForPathString:@":string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[_dictionary valueForPathString:@":integer"] integerValue] == 1, @"");
    STAssertTrue([_dictionary valueForPathString:@":null"] == NSNull.null, @"");
    STAssertTrue([[_dictionary valueForPathString:@":dictionary:string"] isEqualToString:@"string-1"], @"");
    STAssertTrue([[_dictionary valueForPathString:@":dictionary:integer"] integerValue] == 1, @"");
    STAssertTrue([[_dictionary valueForPathString:@":array:0"] isEqualToString:@"string-2"], @"");
    STAssertTrue([[_dictionary valueForPathString:@":array:1"] integerValue] == 2, @"");
    STAssertTrue([[_dictionary valueForPathString:@":array:-5"] isEqualToString:@"string-2"], @"");
    STAssertTrue([[_dictionary valueForPathString:@":array:-4"] integerValue] == 2, @"");
    STAssertTrue([[_dictionary valueForPathString:@":array:-2:string"] isEqualToString:@"string-1"], @"");
    
    [_dictionary setValue:@"string-0" forPathString:@":array:-2:string"];
    STAssertTrue([[_dictionary valueForPathString:@":array:-2:string"] isEqualToString:@"string-0"], @"");
}

@end
