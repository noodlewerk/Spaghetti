//
//  NWSPath.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

/**
 * Path provides a generic way to access and modify object properties.
 */
@interface NWSPath : NSObject

/**
 * Returns the value of the property accessed by this path on object.
 * @param object The subject to which this path will be applied.
 */
- (id)valueWithObject:(NSObject *)object;

/**
 * Modifies the value of the property accessed by this path on object.
 * @param object The subject to which this path will be applied.
 * @param value The new value of this property.
 */
- (void)setWithObject:(NSObject *)object value:(id)value;

/**
 * Parses a path-string into a path. Parsing proceeds in the following order:
 *
 *  - Nil remains nil.
 *  - Empty string become a NWSSelfPath.
 *  - Starting with '=' will be parsed by NWSConstantValuePath.
 *  - Starting with ':' will be parsed by NWSCompositePath.
 *  - Number becomes a NWSIndexPath.
 *  - Containing '.' becomes a NWSKeyPathPath.
 *  - Others become a NWSSingleKeyPath.
 *
 * @param string Any path-string.
 */
+ (NWSPath *)pathFromString:(NSString *)string;

@end



@interface NSObject (NWSPath)

- (id)valueForPath:(NWSPath *)path;
- (void)setValue:(id)value forPath:(NWSPath *)path;
- (id)valueForPathString:(NSString *)string;
- (void)setValue:(id)value forPathString:(NSString *)string;

@end