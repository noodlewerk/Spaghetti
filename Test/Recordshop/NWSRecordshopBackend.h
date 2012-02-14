//
//  NWSRecordshopBackend.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSBackend.h"

@class NWSMultiStore, NWSCoreDataStore, NWSBasicStore, NWSSchedule;

@interface NWSRecordshopBackend : NWSBackend

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NWSMultiStore *store;
@property (nonatomic, strong) NWSCoreDataStore *coreDataStore;
@property (nonatomic, strong) NWSBasicStore *basicStore;
@property (nonatomic, strong) NWSSchedule *schedule;

@end
