//
//  NWSTestDialogue.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTestDialogue.h"
#import "NWSCommon.h"
#import "NWSTestCall.h"


@implementation NWSTestDialogue {
    BOOL cancelled;
}

@synthesize response;


#pragma mark - Object life cycle

- (id)initWithCall:(NWSTestCall *)_call
{
    self = [super initWithCall:_call];
    if (self) {
        response = _call.response;
    }
    return self;
}


#pragma mark - Dialogue process

- (void)start
{
    if (cancelled) {
        return;
    }
    
    NWLogWarnIfNot(response, @"Test requires response data to map");
    
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    id result = [self mapData:data useTransactionStore:NO];
    [self.call doneWithResult:result];
}

- (void)cancel
{
    cancelled = YES;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"test-dialogue" readable:prefix];
}

@end
