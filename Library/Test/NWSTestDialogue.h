//
//  NWSTestDialogue.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSDialogue.h"


/**
 * Dialogue stub for testing.
 * @see NWSTestEndpoint
 * @see NWSTestCall
 */
@interface NWSTestDialogue : NWSDialogue

@property (nonatomic, copy) NSString *response;

@end
