//
//  NWSCommon.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

/**
 * Some object-related conveniences.
 */
@interface NSObject (NWSCommon)

/**
 * Returns a human-readable description of this object.
 */
- (NSString *)readable;

/**
 * Returns a human-readable description indented with a prefix.
 * @param prefix The prefix used for indentation.
 */
- (NSString *)readable:(NSString *)prefix;

- (id)mapWithBlock:(id(^)(id))block;

@end

/**
 * Some array-related conveniences.
 */
@interface NSArray (NWSCommon)

/**
 * Returns a human-readable description of an array, spread over multiple lines if necessary.
 * @param prefix The prefix used for indentation.
 */
- (NSString *)readable:(NSString *)prefix;

@end


/**
 * Some string-related conveniences.
 */
@interface NSString (NWSCommon)

/**
 * Parses the string into an NSNumber using NSNumberFormatterDecimalStyle. Something close to [0-9]+.[0-9]*
 */
- (NSNumber *)number;

@end
