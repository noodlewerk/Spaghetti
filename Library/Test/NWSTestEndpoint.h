//
//  NWSTestEndpoint.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSEndpoint.h"

/**
 * Endpoint stub for testing.
 * @see NWSTestCall
 * @see NWSTestDialogue
 */
@interface NWSTestEndpoint : NWSEndpoint

@property (nonatomic, copy) NSString *response;

@end
