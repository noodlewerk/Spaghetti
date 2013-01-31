//
//  NWSConstantValuePath.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSPath.h"

/**
 * A path that returns a constant value instead of accessing an object's properties.
 *
 * @see NWSPath
 */
@interface NWSConstantValuePath : NWSPath

/**
 * An immutable object (primitive).
 */
@property (nonatomic, strong) id value;

- (id)initWithValue:(id)value;

/**
 * Parses a constant-string, which is of the format `type:value`. Type can be any of the primitives: nil`, `null`, `string`, `int`, `bool`, `integer`, `longlong`, `float`, `double`, or empty. In case of an empty type, the actual type will be inferred based on the value.
 * @param string Any contant-string.
 */
+ (NWSConstantValuePath *)pathFromString:(NSString *)string;

@end
