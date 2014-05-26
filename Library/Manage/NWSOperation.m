//
//  NWSOperation.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSOperation.h"
//#include "NWSLCore.h"


@implementation NWSOperationOwner {
    NSMutableArray *_operations;
}


#pragma mark - Object life cycle

- (id)init
{
    return [self initWithParent:nil];
}

- (id)initWithParent:(NWSOperationOwner *)parent
{
    self = [super init];
    if (self) {
        _operations = [[NSMutableArray alloc] init];
        [parent addOperation:self];
    }
    return self;
}

- (void)dealloc
{
    NWSLogWarnIfNot(_operations.count == 0, @"Did you forget to call 'cancelAllItems'?");
    [self cancelAllOperations];
}


#pragma mark - Operation management

- (void)addOperation:(id<NWSOperation>)operation
{
    if (operation != self) {
        [_operations addObject:operation];
    } else {
        NWSLogWarn(@"Adding operation to itself causes infinite recursion");
    }
}

- (void)cancelAllOperations
{
    for (id<NWSOperation> operation in _operations) {
        [operation cancel];
    }
    [_operations removeAllObjects];
}

- (void)cancel
{
    [self cancelAllOperations];
}

@end
