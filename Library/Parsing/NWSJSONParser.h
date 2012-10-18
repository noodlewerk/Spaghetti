//
//  NWSJSONParser.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSParser.h"

/**
 * A simple wrapper around the NSJSONSerialization decoder/serializer.
 */
@interface NWSJSONParser : NWSParser

+ (id)shared;

@end
