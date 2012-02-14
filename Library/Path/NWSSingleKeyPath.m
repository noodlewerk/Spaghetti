//
//  NWSSingleKeyPath.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSSingleKeyPath.h"
#import "NWSCommon.h"


@implementation NWSSingleKeyPath

@synthesize key;


#pragma mark - Object life cycle

- (id)initWithKey:(NSString *)_key
{
    self = [super init];
    if (self) {
        key = _key;
    }
    return self;
}

- (BOOL)isEqual:(NWSSingleKeyPath *)path
{
    return self == path || (self.class == path.class && [self.key isEqualToString:path.key]);
}

- (NSUInteger)hash
{
    return 8606977022 + key.hash;
}


#pragma mark - Path

- (id)valueWithObject:(NSObject *)object
{
    if (object != NSNull.null) {
        return [object valueForKey:key];
    }
    return NSNull.null;
}

- (void)setWithObject:(NSObject *)object value:(id)value
{
    if (object != NSNull.null) {
        [object setValue:value forKey:key];
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p key:%@>", NSStringFromClass(self.class), self, key];
}

- (NSString *)readable:(NSString *)prefix
{
    return [key readable:prefix];
}

@end
