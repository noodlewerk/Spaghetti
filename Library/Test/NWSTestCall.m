//
//  NWSTestCall.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTestCall.h"
#import "NWSTestDialogue.h"
#import "NWSCommon.h"
#import "NWSTestEndpoint.h"


@implementation NWSTestCall


#pragma mark - Object life cycle

- (id)initWithEndpoint:(NWSTestEndpoint *)endpoint
{
    self = [super initWithEndpoint:endpoint];
    if (self) {
        _response = endpoint.response;
    }
    return self;
}

- (id)newDialogue
{
    return [[NWSTestDialogue alloc] initWithCall:self];
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"test-call" readable:prefix];
}

@end
