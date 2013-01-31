//
//  NWSObjectTypeTest.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NWSClassObjectType.h"
#import "NWSEntityObjectType.h"
#import "NWSCommon.h"
#import "NWSPath.h"


@interface NWSTestClass : NSEntityDescription {
    int ivar;
    NSString *ivarToOne;
    NSSet *ivarToMany;
}
@property (nonatomic, assign) int property;
@property (nonatomic, copy) NSString *propertyToOne;
@property (nonatomic, strong) NSSet *propertyToMany;
@property (nonatomic, assign) BOOL isToMany;
@end
@implementation NWSTestClass
@synthesize property, propertyToOne, propertyToMany, isToMany;
- (NSDictionary *)attributesByName
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"", @"property", @"", @"ivar", nil];
}
- (NSDictionary *)relationshipsByName
{
    NWSTestClass *toOne = [[NWSTestClass alloc] init];
    toOne.isToMany = NO;
    NWSTestClass *toMany = [[NWSTestClass alloc] init];
    toMany.isToMany = YES;
    return [NSDictionary dictionaryWithObjectsAndKeys:toOne, @"propertyToOne", toOne, @"ivarToOne", toMany, @"propertyToMany", nil];
}
- (NSString *)name
{
    return @"";
}
@end



@interface NWSObjectTypeTest : SenTestCase
@end

@implementation NWSObjectTypeTest

- (void)setUp
{
    NWLBreakWarn();
}

- (void)testClassObjectType
{
    NWSClassObjectType *i = [[NWSClassObjectType alloc] initWithClass:NWSTestClass.class];
    
    STAssertTrue([i hasAttribute:[NWSPath pathFromString:@"property"]], @"");
    STAssertTrue([i hasAttribute:[NWSPath pathFromString:@"ivar"]], @"");
    STAssertTrue(![i hasAttribute:[NWSPath pathFromString:@"x"]], @"");
    STAssertTrue([i hasRelation:[NWSPath pathFromString:@"propertyToOne"] toMany:NO], @"");
    STAssertTrue([i hasRelation:[NWSPath pathFromString:@"ivarToOne"] toMany:NO], @"");
    STAssertTrue(![i hasRelation:[NWSPath pathFromString:@"x"] toMany:NO], @"");
    STAssertTrue([i hasRelation:[NWSPath pathFromString:@"propertyToMany"] toMany:YES], @"");
    STAssertTrue([i hasRelation:[NWSPath pathFromString:@"ivarToMany"] toMany:YES], @"");
    STAssertTrue(![i hasRelation:[NWSPath pathFromString:@"x"] toMany:YES], @"");
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.readable, @"");
}

- (void)testEntityObjectType
{
    NWSTestClass *entity = [[NWSTestClass alloc] init];
    NWSEntityObjectType *i = [[NWSEntityObjectType alloc] initWithEntity:entity];
    
    STAssertTrue([i hasAttribute:[NWSPath pathFromString:@"property"]], @"");
    STAssertTrue([i hasAttribute:[NWSPath pathFromString:@"ivar"]], @"");
    STAssertTrue(![i hasAttribute:[NWSPath pathFromString:@"x"]], @"");
    STAssertTrue([i hasRelation:[NWSPath pathFromString:@"propertyToOne"] toMany:NO], @"");
    STAssertTrue([i hasRelation:[NWSPath pathFromString:@"ivarToOne"] toMany:NO], @"");
    STAssertTrue(![i hasRelation:[NWSPath pathFromString:@"x"] toMany:NO], @"");
    STAssertTrue([i hasRelation:[NWSPath pathFromString:@"propertyToMany"] toMany:YES], @"");
    STAssertTrue(![i hasRelation:[NWSPath pathFromString:@"ivarToOne"] toMany:YES], @"");
    STAssertTrue(![i hasRelation:[NWSPath pathFromString:@"x"] toMany:YES], @"");
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.readable, @"");
}

- (void)testObjectType
{
    NWSObjectType *i = [[NWSObjectType alloc] init];
    STAssertNotNil(i.description, @"");
    STAssertNotNil(i.readable, @"");
}

@end