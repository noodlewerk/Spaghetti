//
//  NWSRecordshopBackend.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSRecordshopBackend.h"
#import "NWService.h"


@implementation NWSRecordshopBackend

@synthesize model, context, store, coreDataStore, basicStore, schedule;

- (id)init
{
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load
{
    NSURL *modelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"Recordshop" withExtension:@"momd"];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    
    coreDataStore = [[NWSCoreDataStore alloc] initWithContext:context queue:NSOperationQueue.mainQueue];
    basicStore = [[NWSBasicStore alloc] init];
    store = [[NWSMultiStore alloc] init];
    [store addStore:coreDataStore objectTypeClass:NWSEntityObjectType.class objectIDClass:NWSManagedObjectID.class];
    [store addStore:basicStore objectTypeClass:NWSClassObjectType.class objectIDClass:NWSMemoryObjectID.class];
    
    schedule = [[NWSSchedule alloc] init];
    
    [self setMapping:[[NWSMapping alloc] init] name:@"shop"];
    [self setMapping:[[NWSMapping alloc] init] name:@"record"];
    
    {
        NWSMapping *mapping = [self mappingWithName:@"shop"];
        [mapping setObjectEntityName:@"Shop" model:model];
        [mapping addRelationWithPath:@"records" mapping:[self mappingWithName:@"record"] policy:NWSPolicy.appendMany];
    }
    
    {
        NWSMapping *mapping = [self mappingWithName:@"record"];
        [mapping setObjectEntityName:@"Record" model:model];
        [mapping addAttributeWithPath:@"name"];
        [mapping addAttributeWithPath:@"artist"];
        [mapping addRelationWithPath:@"shop" mapping:[self mappingWithName:@"shop"] policy:NWSPolicy.replaceOne];
    }
    
    [self setEndpoint:[[NWSTestEndpoint alloc] init] name:@"shop"];

    {
        NWSEndpoint *endpoint = [self endpointWithName:@"shop"];
        endpoint.store = store;
        endpoint.responseMapping = [self mappingWithName:@"shop"];
    }
}

@end
