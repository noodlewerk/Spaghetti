//
//  NWSStringParser.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSParser.h"

/**
 * A simple parser that transforms UTF8-encoded data to an NSString.
 */
@interface NWSStringParser : NWSParser

+ (id)shared;

@end
