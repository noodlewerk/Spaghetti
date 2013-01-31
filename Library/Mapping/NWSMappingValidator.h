//
//  NWSMappingValidator.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@class NWSMapping;

/**
 * Reports on the correctness of a mapping's configuration through static analysis.
 *
 * The validator iterates though attributes and relations of a mapping and logs likely problems on the 'warning' tag.
 *
 * NB: make sure to call `NWSLogAdd(tag, warning)` before running the validator.
 */
@interface NWSMappingValidator : NSObject

/**
 * The mapping that is under validation.
 */
@property (nonatomic, strong) NWSMapping *mapping;

/**
 * Validates the attributes of a mapping.
 */
- (void)validateAttributes;

/**
 * Validates the relations of a mapping.
 */
- (void)validateRelations;

/**
 * Validates the primary properties of a mapping.
 */
- (void)validatePrimaryPath;

/**
 * Validates this mapping and reports problems on the 'warning' log tag.
 */
- (void)validate;

/**
 * Validates a mapping and reports problems on the 'warning' log tag.
 *
 * Simply creates a validator object and forwards the validate message.
 * @param mapping The mapping subject.
 */
+ (void)validate:(NWSMapping *)mapping;

@end
