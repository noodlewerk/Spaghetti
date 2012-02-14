//
//  NWSJSONKitParser.h
//  NWService
//
//  Created by leonard on 5/9/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSParser.h"

/**
 * A simple wrapper around the JSONKit decoder/serializer. Uses JKParseOptionStrict for parsing and JKSerializeOptionNone for serialization.
 */
@interface NWSJSONKitParser : NWSParser

+ (id)shared;

@end
