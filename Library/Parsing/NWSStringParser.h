//
//  NWSStringParser.h
//  NWService
//
//  Created by Bruno Scheele on 6/13/12.
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
