//
//  NWSTestDialogue.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTestDialogue.h"
#import "NWSCommon.h"
#import "NWSTestCall.h"


@implementation NWSTestDialogue {
    BOOL _cancelled;
}


#pragma mark - Object life cycle

- (id)initWithCall:(NWSTestCall *)call
{
    self = [super initWithCall:call];
    if (self) {
        _response = call.response;
    }
    return self;
}


#pragma mark - Dialogue process

- (void)start
{
    if (_cancelled) {
        return;
    }
    
    NWLogWarnIfNot(_response, @"Test requires response data to map");
    
    NSData *data = [_response dataUsingEncoding:NSUTF8StringEncoding];
    id result = [self mapData:data useTransactionStore:NO];
    [self.call doneWithResult:result];
}

- (void)cancel
{
    _cancelled = YES;
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
