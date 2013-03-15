//
//  NWSClassObjectType.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSClassObjectType.h"
#import "NWAbout.h"
#include <objc/runtime.h>
#import "NWSPath.h"
#import "NWSSingleKeyPath.h"


@implementation NWSClassObjectType


#pragma mark - Object life cycle

- (id)initWithClass:(Class)clas
{
    self = [super init];
    if (self) {
        _clas = clas;
    }
    return self;
}

- (BOOL)isEqual:(NWSClassObjectType *)type
{
    return self == type || (self.class == type.class && [self.clas isEqual:type.clas]);
}

- (NSUInteger)hash
{
    return 8132572160 + [_clas hash];
}


#pragma mark - Object Type

- (BOOL)matches:(id)object
{
    return [object isKindOfClass:_clas];
}

+ (BOOL)supports:(NSObject *)object
{
    return ![object isKindOfClass:NSManagedObject.class];
}

- (BOOL)hasAttribute:(NWSPath *)attribute
{
    if ([attribute isKindOfClass:NWSSingleKeyPath.class]) {
        NWSSingleKeyPath *path = (NWSSingleKeyPath *)attribute;
        objc_property_t property = class_getProperty(_clas, path.key.UTF8String);
        if (property) {
            return YES;
        }
        Ivar ivar = class_getInstanceVariable(_clas, path.key.UTF8String);
        if (ivar) {
            return YES;
        }
    } else {
        NWLogWarn(@"Path type not yet supported: %@", attribute); // COV_NF_LINE
    }
    return NO;
}

- (BOOL)hasRelation:(NWSPath *)relation toMany:(BOOL)toMany
{
    if ([relation isKindOfClass:NWSSingleKeyPath.class]) {
        NWSSingleKeyPath *path = (NWSSingleKeyPath *)relation;
        objc_property_t property = class_getProperty(_clas, path.key.UTF8String);
        if (property) {
            NSString *type = @(property_getAttributes(property));
            BOOL isToMany = [type rangeOfString:@"NSSet"].length != 0;
            return toMany == isToMany;
        }
        Ivar ivar = class_getInstanceVariable(_clas, path.key.UTF8String);
        if (ivar) {
            NSString *type = @(ivar_getTypeEncoding(ivar));
            // TODO: this condition is a bit too fuzzy
            BOOL isToMany = [type rangeOfString:@"NSSet"].length != 0;
            return toMany == isToMany;
        }
    } else {
        NWLogWarn(@"Path type not yet supported: %@", relation); // COV_NF_LINE
    }
    return NO;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p class:%@>", NSStringFromClass(self.class), self, NSStringFromClass(_clas)];
}

- (NSString *)about:(NSString *)prefix
{
    return [_clas about:prefix];
}

@end
