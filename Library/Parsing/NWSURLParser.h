//
//  NWSURLParser.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSParser.h"

/**
 * A parser for URL-encoded data, supporting both form-urlencoded and multipart data. Strings are encoded using utf-8. NSData is automatically serialized if using multipart.
 */
@interface NWSURLParser : NWSParser

/**
 * Assign an app-specific boundary string to serialize to multipart data. This string should be long and random, e.g. 64 random hex chars, and can be generated with `[NWSURLParser generateHexBoundary:]`. Remember to set this boundary string in the HTTP headers, by setting the 'Content-Type' to 'multipart/form-data; boundary=<multipartBoundary>'.
 */
@property (nonatomic, strong) NSString *multipartBoundary;

/**
 * Returns a random (arc4random) HEX string of given length.
 */
+ (NSString *)generateHexBoundary:(NSUInteger)length;

/**
 * NB: do not manipulate this instance; it's shared.
 */
+ (id)shared;

@end
