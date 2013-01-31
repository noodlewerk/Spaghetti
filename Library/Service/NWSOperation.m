//
//  NWSOperation.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSOperation.h"


@implementation NWSOperationOwner {
    NSMutableArray *operations;
}

@synthesize operations;

#pragma mark - Object life cycle

- (id)init
{
    return [self initWithParent:nil];
}

- (id)initWithParent:(NWSOperationOwner *)parent
{
    self = [super init];
    if (self) {
        operations = [[NSMutableArray alloc] init];
        [parent addOperation:self];
    }
    return self;
}

- (void)dealloc
{
    NWLogWarnIfNot(operations.count == 0, @"Did you forget to call 'cancelAllItems'?");
    [self cancelAllOperations];
}


#pragma mark - Operation management

- (void)addOperation:(id<NWSOperation>)operation
{
    if (operation != self) {
        [operations addObject:operation];
    } else {
        NWLogWarn(@"Adding operation to itself causes infinite recursion");
    }
}

- (void)cancelAllOperations
{
    for (id<NWSOperation> operation in operations) {
        [operation cancel];
    }
    [operations removeAllObjects];
}

- (void)cancel
{
    [self cancelAllOperations];
}

@end
