//
//  NWSSingleKeyPath.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSSingleKeyPath.h"
#import "NWAbout.h"


@implementation NWSSingleKeyPath


#pragma mark - Object life cycle

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
    }
    return self;
}

- (BOOL)isEqual:(NWSSingleKeyPath *)path
{
    return self == path || (self.class == path.class && [self.key isEqualToString:path.key]);
}

- (NSUInteger)hash
{
    return 8606977022 + _key.hash;
}


#pragma mark - Path

- (id)valueWithObject:(NSObject *)object
{
    if (object != NSNull.null) {
        return [object valueForKey:_key];
    }
    return NSNull.null;
}

- (void)setWithObject:(NSObject *)object value:(id)value
{
    if (object != NSNull.null) {
        [object setValue:value forKey:_key];
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p key:%@>", NSStringFromClass(self.class), self, _key];
}

- (NSString *)about:(NSString *)prefix
{
    return [_key about:prefix];
}

@end
