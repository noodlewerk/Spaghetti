//
//  NWSMappingTransform.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"


@class NWSMapping;

/**
 * Transforms an element data structure (dictionary) to an actual object (id), using a mapping.
 *
 * @see NWSMapping
 * @see NWSTransform
 */
@interface NWSMappingTransform : NWSTransform

/**
 * The mapping that is applied to each input value.
 */
@property (nonatomic, strong) NWSMapping *mapping;

/**
 * Init with mapping.
 * @param mapping The mapping that is applied to each input value.
 */
- (id)initWithMapping:(NWSMapping *)mapping;

@end
