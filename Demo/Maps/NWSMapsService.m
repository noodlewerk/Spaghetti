//
//  NWSMapsService.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMapsService.h"

#define MAPPING(__a) [result mappingWithName:__a createWithClass:NWSMapping.class]

@implementation NWSMapsRoute
@synthesize copyrights, summary;
@end

@implementation NWSMapsResponse
@synthesize status, route;
@end

@implementation NWSMapsService

+ (NWSBackend *)backend
{
    NWSBackend *result = [[NWSBackend alloc] init];
    
    {
        NWSMapping *mapping = MAPPING(@"response");
        [mapping setObjectClassName:@"NWSMapsResponse"];
        [mapping addAttributeWithPath:@"status"];
        [mapping addRelationWithPath:@"route" mapping:MAPPING(@"route") policy:NWSPolicy.replaceOne];
    }
    
    {
        NWSMapping *mapping = MAPPING(@"route");
        [mapping setObjectClassName:@"NWSMapsRoute"];
        [mapping addAttributeWithPath:@"copyrights"];
        [mapping addAttributeWithPath:@"summary"];
    }
    
    return result;
}

@end
