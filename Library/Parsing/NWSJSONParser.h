//
//  NWSJSONParser.h
//  NWService
//
//  Created by leonard on 5/9/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSParser.h"

/**
 * A simple wrapper around the NSJSONSerialization decoder/serializer.
 */
@interface NWSJSONParser : NWSParser

+ (id)shared;

@end
