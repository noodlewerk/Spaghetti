//
//  NWSMapsTest.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NWSMapsService.h"

@interface NWSMapsTest : SenTestCase
@end

@implementation NWSMapsTest

- (void)testMaps
{
    NWSBackend *backend = NWSMapsService.backend;
    
    id data = [[NWSXMLParser.shared parse:[NSData dataWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"directions" withExtension:@"xml"]]] valueForKey:@"DirectionsResponse"];
    NWSMapsResponse *response = [[backend mappingWithName:@"response"] objectWithMapElement:data store:NWSAmnesicStore.shared];
    
    STAssertEqualObjects(response.status, @"OK", @"");
    STAssertEqualObjects(response.route.summary, @"Southern Expressway/M2 and A13", @"");
}

@end
