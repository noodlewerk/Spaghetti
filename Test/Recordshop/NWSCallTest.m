//
//  NWSCallTest.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NWService.h"
#import "NWSTestTools.h"
#import "NWSRecordshopBackend.h"


@interface NWSCallTest : SenTestCase
@end


@implementation NWSCallTest

- (void)testCall
{
    NWSRecordshopBackend *backend = [[NWSRecordshopBackend alloc] init];
    NSString *data = @"{records:[{name:'name',artist:'artist'}]}";
    NWSTestEndpoint *endpoint = (NWSTestEndpoint *)[backend endpointWithName:@"shop"];
    NWSTestCall *call = (NWSTestCall *)[endpoint newCall];
    call.response = [NWSTestTools jsonForSQON:data];
    call.doneBlock = ^(NSManagedObject *shop) {
        STAssertNotNil(shop, @"");
        NSMutableSet *records = (NSMutableSet *)[shop mutableSetValueForKey:@"records"];
        NSManagedObject *record = [records anyObject];
        NSString *name = [record valueForKey:@"name"];
        STAssertEqualObjects(name, @"name", @"");
        NSString *artist = [record valueForKey:@"artist"];
        STAssertEqualObjects(artist, @"artist", @"");
    };
    NWSDialogue *dialogue = [call newDialogue];
    [dialogue start];
}

@end
