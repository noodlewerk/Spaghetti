//
//  NWAbout.h
//  NWTools
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

/**
 * The about method retuns a human-readable description of an object. NWAbout provides default implementations for common primitives.
 */
@interface NSObject (NWAbout)

/**
 * Returns a description of this object.
 */
- (NSString *)about;

/**
 * Returns a description indented with a prefix.
 * @param prefix The prefix used for indentation.
 */
- (NSString *)about:(NSString *)prefix;

@end


@interface NSArray (NWAbout)

/**
 * Returns a human-readable description of an array, spread over multiple lines if necessary.
 * @param prefix The prefix used for indentation.
 */
- (NSString *)about:(NSString *)prefix;

@end
