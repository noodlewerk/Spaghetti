//
//  NWSKeyPathPath.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSKeyPathPath.h"
#import "NWAbout.h"


@implementation NWSKeyPathPath


#pragma mark - Object life cycle

- (id)initWithKeyPath:(NSString *)keyPath
{
    self = [super init];
    if (self) {
        _keyPath = [keyPath copy];
    }
    return self;
}

- (BOOL)isEqual:(NWSKeyPathPath *)path
{
    return self == path || (self.class == path.class && [self.keyPath isEqualToString:path.keyPath]);
}

- (NSUInteger)hash
{
    return 1012023143 + _keyPath.hash;
}


#pragma mark - Path

- (id)valueWithObject:(NSObject *)object
{
    if (object != NSNull.null) {
        return [object valueForKeyPath:_keyPath];
    }
    return NSNull.null; 
}

- (void)setWithObject:(NSObject *)object value:(id)value
{
    if (object != NSNull.null) {
        [object setValue:value forKeyPath:_keyPath];
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p keyPath:%@>", NSStringFromClass(self.class), self, _keyPath];
}

- (NSString *)about:(NSString *)prefix
{
    return [_keyPath about:prefix];
}

@end
