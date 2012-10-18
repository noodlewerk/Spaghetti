//
//  NWSParser.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

/**
 * Provides a (de)serialization mechanism that transforms structured data (dictionaries and arrays) to an from plain data.
 */
@interface NWSParser : NSObject

/**
 * Parses a string of data into a nested structure of dictionaries and arrays.
 */
- (id)parse:(NSData *)data;

/**
 * Serializes structured data into a string of data.
 */
- (NSData *)serialize:(id)value;

/**
 * Returns the parser that will be used if none specified.
 */
+ (id)defaultParser;

@end
