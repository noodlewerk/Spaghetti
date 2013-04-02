//
//  NWSTestCall.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSCall.h"

/**
 * Call stub for testing.
 * @see NWSTestEndpoint
 * @see NWSTestDialogue
 */
@interface NWSTestCall : NWSCall

@property (nonatomic, copy) NSString *response;

@end
