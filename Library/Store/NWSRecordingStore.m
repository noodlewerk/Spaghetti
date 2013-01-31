//
//  NWSRecordingStore.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSRecordingStore.h"
#import "NWSCommon.h"
#import "NWSObjectType.h"
#import "NWSObjectID.h"
#import "NWSArrayObjectID.h"
#import "NWSPath.h"
#import "NWSPolicy.h"


@interface NWSRecordObjectID : NWSObjectID
@property (nonatomic, strong) NWSObjectType *type;
@property (nonatomic, strong) NSArray *pathsAndValues;
@property (nonatomic, assign) BOOL create;
@end
@implementation NWSRecordObjectID;
@synthesize type, pathsAndValues, create;
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p type:%@ pathsAndValues:%@ %@>", NSStringFromClass(self.class), self, type, pathsAndValues, create ? @"create" : @"do-not-create"];
}
- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"%@ with %@", [type readable:prefix], [pathsAndValues readable:prefix]] readable:prefix];    
}
@end



@interface NWSRecordObjectType : NWSObjectType
@property (nonatomic, copy) NSString *type;
@end
@implementation NWSRecordObjectType;
@synthesize type;
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p type:%@>", NSStringFromClass(self.class), self, type];
}
- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"%@-type", [type readable:prefix]] readable:prefix];    
}
@end



@implementation NWSAttributeRecord;
@synthesize identifier, path, value;
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p identifier:%@ path:%@ value:%@>", NSStringFromClass(self.class), self, identifier, path, value];
}
- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"On %@ set %@ := %@", [identifier readable:prefix], [path.readable readable:prefix], [value readable:prefix]] readable:prefix];    
}
@end



@implementation NWSRelationRecord;
@synthesize identifier, path, value, policy;
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p identifier:%@ path:%@ value:%@ policy:%@>", NSStringFromClass(self.class), self, identifier, path, value, policy];
}
- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"On %@ set %@ := %@ (%@)", [identifier readable:prefix], [path readable:prefix], [value readable:prefix], [policy readable:prefix]] readable:prefix];    
}
@end



@implementation NWSRecordingStore

@synthesize records;


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        records = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - Store subclass

- (NWSObjectID *)identifierWithType:(NWSObjectType *)type primaryPathsAndValues:(NSArray *)pathsAndValues create:(BOOL)create
{
    NWLogInfo(@"identifierWithType: %@ %@ %@", type, pathsAndValues, create ? @"create" : @"do-not-create");
    NWSRecordObjectID *result = [[NWSRecordObjectID alloc] init];
    result.type = type;
    result.pathsAndValues = pathsAndValues;
    result.create = create;
    return result;
}

- (id)attributeForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path
{
    NWLogWarn(@"Recording store is unable to provide such information");
    return nil;
}

- (NWSObjectID *)relationForIdentifier:(NWSObjectID *)identifier path:(NWSPath *)path
{
    NWLogWarn(@"Recording store is unable to provide such information");
    return nil;
}

- (void)setAttributeForIdentifier:(NWSObjectID *)identifier value:(id)value path:(NWSPath *)path
{
    NWLogInfo(@"setAttributeForIdentifier: %@, %@ = %@", identifier, path, value);
    NWSAttributeRecord *record = [[NWSAttributeRecord alloc] init];
    record.identifier = identifier;
    record.value = value;
    record.path = path;
    [records addObject:record];
}

- (void)setRelationForIdentifier:(NWSObjectID *)identifier value:(NWSObjectID *)value path:(NWSPath *)path policy:(NWSPolicy *)policy baseStore:(NWSStore *)baseStore
{
    NWLogInfo(@"setRelationForIdentifier: %@, %@ = %@ (%@)", identifier, path, value, policy);
    NWSRelationRecord *record = [[NWSRelationRecord alloc] init];
    record.identifier = identifier;
    record.value = value;
    record.path = path;
    record.policy = policy;
    [records addObject:record];
}

- (void)deleteObjectWithIdentifier:(NWSObjectID *)identifier
{
    NWLogWarn(@"Recording store does not support object deletion");
}

- (NWSObjectReference *)referenceForIdentifier:(NWSObjectID *)identifier
{
    NWLogWarn(@"Recording store does not support object fetching");
    return nil;
}

- (NWSObjectID *)applyIdentifier:(NWSObjectID *)identifier store:(NWSStore *)store
{
    if ([identifier isKindOfClass:NWSRecordObjectID.class]) {
        NWSRecordObjectID *i = (NWSRecordObjectID *)identifier;
        NWSObjectType *type = i.type;
        if ([type isKindOfClass:NWSRecordObjectType.class]) {
            type = [store typeFromString:[(NWSRecordObjectType *)type type]];
        }
        return [store identifierWithType:i.type primaryPathsAndValues:i.pathsAndValues create:i.create];
    }
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        NSArray *identifiers = ((NWSArrayObjectID *)identifier).identifiers;
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:identifiers.count];
        for (NWSObjectID *i in identifiers) {
            [results addObject:[self applyIdentifier:i store:store]];
        }
        return [[NWSArrayObjectID alloc] initWithIdentifiers:results];
    }
    return identifier;
}

- (void)applyToStore:(NWSStore *)store
{
    for (id record in records) {
        if ([record isKindOfClass:NWSAttributeRecord.class]) {
            NWSAttributeRecord *r = (NWSAttributeRecord *)record;
            NWSObjectID *identifier = [self applyIdentifier:r.identifier store:store];
            [store setAttributeForIdentifier:identifier value:r.value path:r.path];
        } else if ([record isKindOfClass:NWSRelationRecord.class]) {
            NWSRelationRecord *r = (NWSRelationRecord *)record;
            NWSObjectID *identifier = [self applyIdentifier:r.identifier store:store];
            NWSObjectID *value = [self applyIdentifier:r.value store:store];
            [store setRelationForIdentifier:identifier value:value path:r.path policy:r.policy baseStore:nil];
        } else {
            NWLogWarn(@"Record class not supported: %@", record);
        }
    }
    [records removeAllObjects];
}

- (NWSObjectType *)typeFromString:(NSString *)string
{
    NWSRecordObjectType *result = [[NWSRecordObjectType alloc] init];
    result.type = string;
    return result;
}


#pragma mark - Transaction management

- (NWSStore *)beginTransaction
{
    return self;
}

- (void)mergeTransaction:(NWSStore *)store
{
    // noop
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p #records:%u>", NSStringFromClass(self.class), self, (int)records.count];
}

- (NSString *)readable:(NSString *)prefix
{
    return [@"reading-store" readable:prefix];
}


#if DEBUG

- (NSArray *)allObjects
{
    NWLogWarn(@"Recording store does not support object fetching");
    return nil;
}

#endif

@end
