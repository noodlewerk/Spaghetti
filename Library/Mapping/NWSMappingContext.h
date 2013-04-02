//
//  NWSMappingContext.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NWSStore, NWSPath;

// path stack is only available in debug
#if DEBUG
#define DEBUG_CONTEXT_PUSH(__context,__path) [(__context) pushPath:(__path)]
#define DEBUG_CONTEXT_POP(__context) [(__context) popPath]
#else
#define DEBUG_CONTEXT_PUSH(__context,__path)
#define DEBUG_CONTEXT_POP(__context)
#endif

/**
 * The mapping context is a set of objects that are available during the mapping process.
 *
 * The mapping context is provided to mappings and transforms to allow access to for example the object store.
 *
 * @see NWSMapping
 * @see NWSStore
 */
@interface NWSMappingContext : NSObject

/**
 * The store this context is based on.
 */
@property (nonatomic, strong) NWSStore *store;

/**
 * The index of currently mapped object in the element array above. For example, we map the array:
 * 
 *     [
 *         {"name":"a"},
 *         {"name":"b","child":{"name":"c"}}
 *     ]
 *
 * When mapping object with name 'a', the indexInArray == 0, and when mapping object 'b' and 'c', the indexInArray == 1.
 *
 * This is primarily used for setting the order key.
 */
@property (nonatomic, readonly) NSUInteger indexInArray;

- (id)initWithStore:(NWSStore *)store;

/**
 * Marks the value as 'done'.
 * @param value Subject
 */
- (void)doing:(id)value;

/**
 * Returns true if the value was marked 'done'.
 * @param value Subject
 */
- (BOOL)did:(id)value;

/**
 * Push the current index on the stack and set to zero.
 * @see indexInArray
 */
- (void)pushIndexInArray;

/**
 * Increment the current index by one.
 * @see indexInArray
 */
- (void)incIndexInArray;

/**
 * Pop the current index from the stack.
 * @see indexInArray
 */
- (void)popIndexInArray;

#if DEBUG
- (void)pushPath:(NWSPath *)path;
- (void)popPath;
- (NWSPath *)pathStack;
#endif

- (NSString *)path;

@end
