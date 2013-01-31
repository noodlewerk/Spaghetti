//
//  NWSKeyPathPath.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSKeyPathPath.h"
#import "NWSCommon.h"


@implementation NWSKeyPathPath

@synthesize keyPath;


#pragma mark - Object life cycle

- (id)initWithKeyPath:(NSString *)_keyPath
{
    self = [super init];
    if (self) {
        keyPath = [_keyPath copy];
    }
    return self;
}

- (BOOL)isEqual:(NWSKeyPathPath *)path
{
    return self == path || (self.class == path.class && [self.keyPath isEqualToString:path.keyPath]);
}

- (NSUInteger)hash
{
    return 1012023143 + keyPath.hash;
}


#pragma mark - Path

- (id)valueWithObject:(NSObject *)object
{
    if (object != NSNull.null) {
        return [object valueForKeyPath:keyPath];
    }
    return NSNull.null; 
}

- (void)setWithObject:(NSObject *)object value:(id)value
{
    if (object != NSNull.null) {
        [object setValue:value forKeyPath:keyPath];
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p keyPath:%@>", NSStringFromClass(self.class), self, keyPath];
}

- (NSString *)readable:(NSString *)prefix
{
    return [keyPath readable:prefix];
}

@end
