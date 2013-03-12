//
//  NWSDialogue.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSDialogue.h"
#import "NWSCall.h"
#import "NWSEndpoint.h"
#import "NWSVarStat.h"
#import "NWSSelfPath.h"
#import "NWSStore.h"
#import "NWSMapping.h"
#import "NWSObjectReference.h"
#import "NWSParser.h"
#import "NWSAmnesicStore.h"


@implementation NWSDialogue


#pragma mark - Object life cycle

- (id)initWithCall:(NWSCall *)call
{
    self = [super init];
    if (self) {
        _call = call;
        _indicator = call.indicator;
    }
    return self;
}


#pragma mark - Operation

- (void)start // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");    
} // COV_NF_END

- (void)cancel // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");    
} // COV_NF_END


- (id)mapData:(NSData *)data useTransactionStore:(BOOL)useStore
{
    if (!data.length) {
        NWLogWarn(@"empty response");
        return nil;
    }
    
    // parsing
    NWSParser *parser = _call.responseParser;
    if (!parser) {
        parser = NWSParser.defaultParser;
    }
    NWLogInfo(@"parsing data (expected:%.3fs)", _call.endpoint.parseTime.average);
    DEBUG_STAT_START(parseTime);
    id parsed = [parser parse:data];
    DEBUG_STAT_STOP(parseTime, _call.endpoint);
    if (!parsed) {
        NWLogWarn(@"failed to parse");
        return nil;
    }
    
    // take value at response path
    NWSPath *p = _call.responsePath;
    if (!p) {
        p = NWSSelfPath.shared;
    }
    id value = [parsed valueForPath:p];
    if (!value) {
        NWLogWarn(@"no value at response path");
        return nil;
    }
    
    id result = nil;
    NWSMapping *mapping = _call.responseMapping;
    if (mapping) {
        // if needed, default to amnesic store
        NWSStore *store = _call.store;
        if (!store) {
            store = NWSAmnesicStore.shared;
        }
        
        // if required, create transaction store
        NWSStore *tempStore = nil;
        if (useStore) {
            // split off store to perform mapping with
            tempStore = [store beginTransaction];
        } else {
            tempStore = store;
        }
        
        // perform actual mapping
        NWLogInfo(@"mapping tree (expected:%.3fs)", _call.endpoint.mappingTime.average);
        DEBUG_STAT_START(mappingTime);
        NWSObjectID *identifier = [mapping mapElement:value store:tempStore];
        DEBUG_STAT_STOP(mappingTime, _call.endpoint);
        if (!identifier) {
            NWLogWarn(@"mapping result is nil");
            return nil;
        }
        
        // parent assignment
        if (_call.parent) {
            NWLogWarnIfNot(_call.parentPath, @"Parent was set, but no path provided");
            NWLogWarnIfNot(_call.parentPolicy, @"Parent was set, but no setter policy");
            NWSObjectID *parentIdentifier = [tempStore identifierForObject:_call.parent];
            [tempStore setRelationForIdentifier:parentIdentifier value:identifier path:_call.parentPath policy:_call.parentPolicy baseStore:nil];
        }
        
        // extract result
        NWSObjectReference *reference = [tempStore referenceForIdentifier:identifier];
        if (useStore) {
            // merge-back the split-off store (this will automatically migrate object references)
            [store mergeTransaction:tempStore];
        }
        // cleanup (migrated) references
        result = reference.dereference;
    } else {
        result = value;
    }
    
    // report done
    return result;
}

- (NSData *)mapObject:(NSObject *)object
{
    if (!object) {
        NWLogWarn(@"no object to serialize");
        return nil;
    }
    
    id data = nil;
    NWSMapping *mapping = _call.requestMapping;
    if (mapping) {
        NWSStore *store = _call.store;
        NWLogWarnIfNot(store, @"Unable to map response without a store (with objects)");
        NWSObjectID *identifier = [store identifierForObject:object];
        data = [mapping mapIdentifier:identifier store:store];
    } else {
        data = object;
    }
    
    NWSParser *parser = _call.requestParser;
    if (!parser) {
        parser = NWSParser.defaultParser;
    }
    NWLogInfo(@"serializing object");
    NSData *result = [parser serialize:data];
    if (!result) {
        NWLogWarn(@"failed to serialize");
        return nil;
    }
    return result;
}

@end
