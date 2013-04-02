//
//  NWSAmnesicStore.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSStore.h"

/**
 * A basic in-memory store, similar to the basic store, but without any internal object collection.
 *
 * The amnesic store provides all the means to get and set attributes and relations of in-memory objects. It however does not keep a reference to the objects created and therefore does not support any object fetching or primary key referencing. This makes the amnesic store very efficient and a likely choice for the temporary mapping of data in memory.
 */
@interface NWSAmnesicStore : NWSStore

+ (NWSAmnesicStore *)shared;

@end
