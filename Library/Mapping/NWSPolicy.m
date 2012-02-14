//
//  NWSPolicy.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSPolicy.h"
#import "NWSCommon.h"


@implementation NWSPolicy

@synthesize type, toMany;


#pragma mark - Object life cycle

- (id)initWithPolicy:(NWSPolicyType)_type toMany:(BOOL)_toMany;
{
    self = [super init];
    if (self) {
        type = _type;
        toMany = _toMany;
    }
    return self;
}

+ (NWSPolicy *)replaceOne
{
    static NWSPolicy *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSPolicy alloc] initWithPolicy:kNWSPolicyReplace toMany:NO];
    });
    return result;
}

+ (NWSPolicy *)replaceMany
{
    static NWSPolicy *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSPolicy alloc] initWithPolicy:kNWSPolicyReplace toMany:YES];
    });
    return result;
}

+ (NWSPolicy *)appendMany
{
    static NWSPolicy *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSPolicy alloc] initWithPolicy:kNWSPolicyAppend toMany:YES];
    });
    return result;
}

+ (NWSPolicy *)deleteOne
{
    static NWSPolicy *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSPolicy alloc] initWithPolicy:kNWSPolicyDelete toMany:NO];
    });
    return result;
}

+ (NWSPolicy *)deleteMany
{
    static NWSPolicy *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSPolicy alloc] initWithPolicy:kNWSPolicyDelete toMany:YES];
    });
    return result;
}


#pragma mark - Logging

+ (NSString *)stringFromType:(NWSPolicyType)type
{
    switch (type) {
        case kNWSPolicyReplace: return @"kNWSPolicyReplace";
        case kNWSPolicyAppend: return @"NWSPolicyAppend";
        case kNWSPolicyDelete: return @"kNWSPolicyDelete";
    }            
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p %@>", NSStringFromClass(self.class), self, [NWSPolicy stringFromType:type]];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"setter-policy" readable:prefix];
}

@end
