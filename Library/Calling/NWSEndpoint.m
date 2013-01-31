//
//  NWSEndpoint.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSEndpoint.h"
#import "NWSCommon.h"
#import "NWSVarStat.h"
#import "NWSSelfPath.h"
#import "NWSCall.h"
#import "NWSParser.h"

@implementation NWSEndpoint

@synthesize store;
@synthesize requestParser, requestMapping, requestObject, responseParser, responseMapping, responsePath;
@synthesize parentPath, parentPolicy;
@synthesize indicator;

#if DEBUG
@synthesize mappingTime, parseTime, totalTime, requestTime;
#endif


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
#if DEBUG
        mappingTime = [[NWSVarStat alloc] init];
        parseTime = [[NWSVarStat alloc] init];
        totalTime = [[NWSVarStat alloc] init];
        requestTime = [[NWSVarStat alloc] init];
#endif
    }
    return self;
}

- (id)newCall // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (id)copyWithZone:(NSZone *)zone
{
    NWSEndpoint *result = [[self.class allocWithZone:zone] init];
    result.store = store;
    result.requestParser = requestParser;
    result.requestMapping = requestMapping;
    result.requestObject = requestObject;
    result.responseParser = responseParser;
    result.responseMapping = responseMapping;
    result.responsePath = responsePath;
    result.parentPath = parentPath;
    result.parentPolicy = parentPolicy;
    result.indicator = indicator;
    return result;
}

#if !DEBUG
- (NWSVarStat *)mappingTime {return nil;}
- (NWSVarStat *)parseTime {return nil;}
- (NWSVarStat *)totalTime {return nil;}
- (NWSVarStat *)requestTime {return nil;}
#endif

#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass(self.class), self];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"endpoint" readable:prefix];
}

@end
