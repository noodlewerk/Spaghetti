//
//  NWSMapping.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMapping.h"
#import "NWSCommon.h"
#import "NWSObjectID.h"
#import "NWSTransform.h"
#import "NWSStore.h"
#import "NWSMappingContext.h"
#import "NWSClassObjectType.h"
#import "NWSSingleKeyPath.h"
#import "NWSMappingTransform.h"
#import "NWSArrayTransform.h"
#import "NWSEntityObjectType.h"
#import "NWSPolicy.h"
#import "NWSIDToObjectTransform.h"
#import "NWSArrayObjectID.h"
#import "NWSSelfPath.h"
#import "NWSIndexPath.h"
#import "NWSIdentityTransform.h"
#import "NWSObjectReference.h"


@implementation NWSMappingEntry

@synthesize elementPath, objectPath, transform, policy;

- (id)initWithElementPath:(NWSPath *)_elementPath objectPath:(NWSPath *)_objectPath transform:(NWSTransform *)_transform policy:(NWSPolicy *)_policy
{
    NWLogWarnIfNot(_elementPath, @"Element path should be non-nil");
    NWLogWarnIfNot(_objectPath, @"Object path should be non-nil");
    NWLogWarnIfNot(_transform, @"Transform should be non-nil");
    NWLogWarnIfNot(_policy, @"Policy should be non-nil");
    self = [super init];
    if (self) {
        elementPath = _elementPath;
        objectPath = _objectPath;
        transform = _transform;
        policy = _policy;
    }
    return self;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p element:%@ attribute:%@ transform:%@>", NSStringFromClass(self.class), self, elementPath, objectPath, transform];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"map-entry %@ -> %@ using %@", [elementPath readable:prefix], [objectPath readable:prefix], [transform readable:prefix]] readable:prefix];
}

@end


@implementation NWSMapping {
    NSMutableArray *attributes;
    NSMutableArray *relations;
    NSMutableArray *primaries;
}

@synthesize attributes, relations, primaries, objectType;


#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self) {
        attributes = [[NSMutableArray alloc] init];
        relations = [[NSMutableArray alloc] init];
        primaries = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithAttributes:(NSMutableArray *)_attributes relations:(NSMutableArray *)_relations primaries:(NSMutableArray *)_primaries
{
    self = [super init];
    if (self) {
        attributes = _attributes;
        relations = _relations;
        primaries = _primaries;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NWSMapping *result = [[self.class allocWithZone:zone] initWithAttributes:[attributes mutableCopy] relations:[relations mutableCopy] primaries:[primaries mutableCopy]];
    return result;
}

- (void)breakCycles
{
    [relations removeAllObjects];
}


#pragma mark - Accessors

- (void)setObjectClassName:(NSString *)className
{
    Class clas = NSClassFromString(className);
    NWLogWarnIfNot(clas, @"Class not found: %@", className);
    self.objectType = [[NWSClassObjectType alloc] initWithClass:clas];
}

- (void)setObjectEntityName:(NSString *)entityName model:(NSManagedObjectModel *)model
{
    NSEntityDescription *entity = [model.entitiesByName objectForKey:entityName];
    NWLogWarnIfNot(entity, @"Entity not found: %@", entityName);
    self.objectType = [[NWSEntityObjectType alloc] initWithEntity:entity];
}

- (void)addAttributeEntry:(NWSMappingEntry *)entry isPrimary:(BOOL)isPrimary
{
    [attributes addObject:entry];
    if (isPrimary) {
        [primaries addObject:entry];
    }
}

- (void)addRelationEntry:(NWSMappingEntry *)entry
{
    [relations addObject:entry];
}


#pragma mark - Attribute Convenience

- (void)addAttributeWithPath:(NSString *)path
{
    [self addAttributeWithPath:path isPrimary:NO];
}

- (void)addAttributeWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath
{
    [self addAttributeWithElementPath:elementPath objectPath:objectPath isPrimary:NO];
}

- (void)addAttributeWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath transform:(NWSTransform *)transform
{
    [self addAttributeWithElementPath:elementPath objectPath:objectPath transform:transform isPrimary:NO];
}

- (void)addAttributeWithPath:(NSString *)path isPrimary:(BOOL)isPrimary
{
    NWSPath *p = [NWSPath pathFromString:path];
    NWSMappingEntry *attribute = [[NWSMappingEntry alloc] initWithElementPath:p objectPath:p transform:NWSIdentityTransform.shared policy:NWSPolicy.replaceOne];
    [self addAttributeEntry:attribute isPrimary:isPrimary];
}

- (void)addAttributeWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath isPrimary:(BOOL)isPrimary
{
    NWSMappingEntry *attribute = [[NWSMappingEntry alloc] initWithElementPath:[NWSPath pathFromString:elementPath] objectPath:[NWSPath pathFromString:objectPath] transform:NWSIdentityTransform.shared policy:NWSPolicy.replaceOne];
    [self addAttributeEntry:attribute isPrimary:isPrimary];
}

- (void)addAttributeWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath transform:(NWSTransform *)transform isPrimary:(BOOL)isPrimary
{
    NWSMappingEntry *attribute = [[NWSMappingEntry alloc] initWithElementPath:[NWSPath pathFromString:elementPath] objectPath:[NWSPath pathFromString:objectPath] transform:transform policy:NWSPolicy.replaceOne];
    [self addAttributeEntry:attribute isPrimary:isPrimary];
}

- (void)addAttributeWithObjectPath:(NSString *)objectPath transform:(NWSTransform *)transform isPrimary:(BOOL)isPrimary
{
    [self addAttributeWithElementPath:@"" objectPath:objectPath transform:transform isPrimary:isPrimary];
}


#pragma mark - Relation Convenience

- (void)addRelationWithPath:(NSString *)path mapping:(NWSMapping *)mapping policy:(NWSPolicy *)policy
{
    [self addRelationWithElementPath:path objectPath:path mapping:mapping policy:policy];
}

- (void)addRelationWithPath:(NSString *)path className:(NSString *)className primary:(NSString *)primary policy:(NWSPolicy *)policy
{
    [self addRelationWithElementPath:path objectPath:path className:className primary:primary policy:policy];
}

- (void)addRelationWithPath:(NSString *)path entityName:(NSString *)entityName model:(NSManagedObjectModel *)model primary:(NSString *)primary policy:(NWSPolicy *)policy
{
    [self addRelationWithElementPath:path objectPath:path entityName:entityName model:model primary:primary policy:policy];
}

- (void)addRelationWithPath:(NSString *)path transform:(NWSTransform *)transform policy:(NWSPolicy *)policy
{
    [self addRelationWithElementPath:path objectPath:path transform:transform policy:policy];
}

- (void)addRelationWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath mapping:(NWSMapping *)mapping policy:(NWSPolicy *)policy
{
    if (mapping) {
        NWSTransform *transform = [[NWSMappingTransform alloc] initWithMapping:mapping];
        [self addRelationWithElementPath:elementPath objectPath:objectPath transform:transform policy:policy];
    } else {
        NWLogWarn(@"Mapping not set, did you create it in the backend?");
    }
}

- (void)addRelationWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath className:(NSString *)className primary:(NSString *)primary policy:(NWSPolicy *)policy
{
    Class clas = NSClassFromString(className);
    if (clas) {
        NWSTransform *transform = [[NWSIDToObjectTransform alloc] initWithType:[[NWSClassObjectType alloc] initWithClass:clas] path:[NWSPath pathFromString:primary]];
        [self addRelationWithElementPath:elementPath objectPath:objectPath transform:transform policy:policy];
    } else {
        NWLogWarn(@"Class not found: %@, typo?", className);
    }
}

- (void)addRelationWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath entityName:(NSString *)entityName model:(NSManagedObjectModel *)model primary:(NSString *)primary policy:(NWSPolicy *)policy
{
    NSEntityDescription *entity = [model.entitiesByName objectForKey:entityName];
    if (entity) {
        NWSTransform *transform = [[NWSIDToObjectTransform alloc] initWithType:[[NWSEntityObjectType alloc] initWithEntity:entity] path:[NWSPath pathFromString:primary]];
        [self addRelationWithElementPath:elementPath objectPath:objectPath transform:transform policy:policy];
    } else {
        NWLogWarn(@"Entity not found: %@  in model: %@, typo?", entityName, model);
    }
}

- (void)addRelationWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath transform:(NWSTransform *)transform policy:(NWSPolicy *)policy
{
    if (transform) {
        if (policy.toMany) {
            transform = [[NWSArrayTransform alloc] initWithTransform:transform];
        }
        NWSMappingEntry *relation = [[NWSMappingEntry alloc] initWithElementPath:[NWSPath pathFromString:elementPath] objectPath:[NWSPath pathFromString:objectPath] transform:transform policy:policy];
        [self addRelationEntry:relation];
    } else {
        NWLogWarn(@"Transform not set, did you create it in de backend?");
    }
}

- (void)addRelationWithObjectPath:(NSString *)objectPath transform:(NWSTransform *)transform policy:(NWSPolicy *)policy
{
    [self addRelationWithElementPath:nil objectPath:objectPath transform:transform policy:policy];
}


#pragma mark - Mapping

- (id)objectWithMapElement:(NSObject *)element store:(NWSStore *)store
{
    NWSObjectID *i = [self mapElement:element store:store];
    NWSObjectReference *r = [store referenceForIdentifier:i];
    id result = [r dereference];
    return result;
}

- (NWSObjectID *)mapElement:(NSObject *)element store:(NWSStore *)store
{
    NWSMappingContext *context = [[NWSMappingContext alloc] initWithStore:store];
    NWSObjectID *result = [self mapElement:element context:context];
    return result;
}

- (NWSObjectID *)mapElement:(NSObject *)element context:(NWSMappingContext *)context
{
    NWSObjectID *result = nil;
    
    NWLogInfo(@"start mapping: %@", context.path);
    
    if ([element isKindOfClass:NSDictionary.class]) {    
        // if we have a primary path, first search for existing object to map to
        if (objectType) {
            NSMutableArray *pathsAndValues = [[NSMutableArray alloc] initWithCapacity:primaries.count * 2];
            for (NWSMappingEntry *primary in primaries) {
                id value = [element valueForPath:primary.elementPath];
                if (value == NSNull.null) {
                    value = nil;
                }
                id transformed = [primary.transform transform:value context:context];
                if (transformed) {
                    [pathsAndValues addObject:primary.objectPath];
                    [pathsAndValues addObject:transformed];
                }
            }
            result = [context.store identifierWithType:objectType primaryPathsAndValues:pathsAndValues create:YES];
            NWLogWarnIfNot(result, @"No identifier found or created");
            NWLogInfo(@"found/created object: %@", result);
        }   
        
        // perform individual mapEntries
        for (NWSMappingEntry *attribute in attributes) {
            id value = [element valueForPath:attribute.elementPath];
            if (value) {
                if (value == NSNull.null) {
                    value = nil;
                }
                DEBUG_CONTEXT_PUSH(context, attribute.elementPath);
                NWLogInfo(@"mapElement attribute: %@ = %@", context.path, value);
                id transformed = [attribute.transform transform:value context:context];
                DEBUG_CONTEXT_POP(context);
                // if we have a subject to assign to
                if (result) {
                    [context.store setAttributeForIdentifier:result value:transformed path:attribute.objectPath];        
                }
            } else {
                // else mapElement key not present in element
                NWLogInfo(@"no element for attribute: %@", attribute);
            }
        }
        
        // queue individual relations
        for (NWSMappingEntry *relation in relations) {
            id value = [element valueForPath:relation.elementPath];
            if (value) {
                if (value == NSNull.null) {
                    value = nil;
                }
                DEBUG_CONTEXT_PUSH(context, relation.elementPath);
                NWLogInfo(@"mapElement relation: %@", context.path);
                id transformed = [relation.transform transform:value context:context];
                DEBUG_CONTEXT_POP(context);
                // if we have a subject to assign to
                if (result) {
                    [context.store setRelationForIdentifier:result value:transformed path:relation.objectPath policy:relation.policy baseStore:nil];        
                }
            } else {
                // else mapElement key not present in entry
                NWLogInfo(@"no entry for relation: %@", relation);
            }
        }
    } else if ([element isKindOfClass:NSArray.class]) {
        // map arrays per-element
        NSArray *array = (NSArray *)element;
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:array.count];
        // TODO: consider a more generic (and safe) appraoch to storing index in context
        [context pushIndexInArray];
        for (id i in array) {
            DEBUG_CONTEXT_PUSH(context, [[NWSIndexPath alloc] initWithIndex:context.indexInArray]);
            NWSObjectID *mapped = [self mapElement:i context:context];
            DEBUG_CONTEXT_POP(context);
            if (mapped) {
                [results addObject:mapped];
            } else {
                NWLogWarn(@"Unable to add nil object to array (element:%@ path:%@)", i, context.path);
            }
            [context incIndexInArray];
        }
        [context popIndexInArray];
        result = [[NWSArrayObjectID alloc] initWithIdentifiers:results];
        
    } else {
        NWLogWarn(@"Unable to map element: %@ (class:%@ path:%@)", element, element.class, context.path);
    }
    
    NWLogInfo(@"done mapping: %@", context.path);
       
    return result;
}

- (id)mapIdentifierWithObject:(id)object store:(NWSStore *)store
{
    NWSObjectID *i = [store identifierForObject:object];
    NSObject *result = [self mapIdentifier:i store:store];
    return result;
}

- (NSObject *)mapIdentifier:(NWSObjectID *)identifier store:(NWSStore *)store
{
    NWSMappingContext *context = [[NWSMappingContext alloc] initWithStore:store];
    NSObject *result = [self mapIdentifier:identifier context:context];
    return result;
}

- (NSObject *)mapIdentifier:(NWSObjectID *)identifier context:(NWSMappingContext *)context
{
    NWLogWarnIfNot([identifier isKindOfClass:NWSObjectID.class], @"Identifier should be of class NWSObjectID: %@", identifier);
    NWLogWarnIfNot(context, @"Expecting non-nil context to map with");
    
    NSObject *result = nil;
    
    if ([identifier isKindOfClass:NWSArrayObjectID.class]) {
        // map arrays per-element
        NWSArrayObjectID *ids = (NWSArrayObjectID *)identifier;
        result = [[NSMutableArray alloc] initWithCapacity:ids.identifiers.count];
        for (NWSObjectID *i in ids.identifiers) {
            DEBUG_CONTEXT_PUSH(context, [NWSPath pathFromString:@"#"]);
            NSObject *mapped = [self mapIdentifier:i context:context];
            DEBUG_CONTEXT_POP(context);
            if (mapped) {
                [(NSMutableArray *)result addObject:mapped];
            } else {
                [(NSMutableArray *)result addObject:NSNull.null];
            }
        }
    } else {
        result = [[NSMutableDictionary alloc] init];
        
        if ([context did:identifier]) {
            // we already did this one, so only map primaries
            for (NWSMappingEntry *primary in primaries) {
                id value = [context.store attributeForIdentifier:identifier path:primary.objectPath];
                if (value == NSNull.null) {
                    value = nil;
                }
                id transformed = [primary.transform reverse:value context:context];
                [result setValue:transformed forPath:primary.elementPath];
            }
            return result;
        }
        
        [context doing:identifier];
        
        // perform individual mapEntries
        for (NWSMappingEntry *attribute in attributes) {
            id value = [context.store attributeForIdentifier:identifier path:attribute.objectPath];
            DEBUG_CONTEXT_PUSH(context, attribute.objectPath);
            NWLogInfo(@"mapElement attribute: %@ = %@", context.path, value);
            id reversed = [attribute.transform reverse:value context:context];
            DEBUG_CONTEXT_POP(context);
            if (reversed == nil) {
                reversed = NSNull.null;
            }
            [result setValue:reversed forPath:attribute.elementPath];
        }
        
        // queue individual relations
        for (NWSMappingEntry *relation in relations) {
            id value = [context.store relationForIdentifier:identifier path:relation.objectPath];
            DEBUG_CONTEXT_PUSH(context, relation.objectPath);
            NWLogInfo(@"mapElement relation: %@", context.path);
            id reversed = [relation.transform reverse:value context:context];
            DEBUG_CONTEXT_POP(context);
            if (reversed == nil) {
                reversed = NSNull.null;
            }
            [result setValue:reversed forPath:relation.elementPath];
        }
    }
    
    return result;
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p type:%@ #attributes:%u #relations:%u #primaries:%u>", NSStringFromClass(self.class), self, objectType, (int)attributes.count, (int)relations.count, (int)primaries.count];
}

- (NSString *)readable:(NSString *)prefix
{
    return [[NSString stringWithFormat:@"mapping for %@", [objectType readable:prefix]] readable:prefix];
}

@end
