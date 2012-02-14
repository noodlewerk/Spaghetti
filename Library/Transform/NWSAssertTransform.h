//
//  NWSAssertTransform.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"

typedef BOOL(^NWSAssertBlock)(id value);

/**
 * An identity transform that tests the input to be equal to certain value and asserts if it doesn't match.
 *
 * This transform can be used to test the element data for a certain value, for example to get notified when the backend changes.
 */
@interface NWSAssertTransform : NWSTransform

/** @name Configuring transform */

/**
 * The value that is assumed to be input into the forward transform.
 */
@property (nonatomic, strong) id forward;

/**
 * The value that is assumed to be input into the reverse transform.
 */
@property (nonatomic, strong) id reverse;

/**
 * If YES, this transform will not assert, but instead log on the 'warning' tag.
 * @see NWSLog
 */
@property (nonatomic, assign) BOOL logInstead;

/** @name Initializing transform */

/**
 * Init this transform with one value for both the forward and reverse test.
 * @param value Assigned to both forward and reverse.
 */
- (id)initWithValue:(id)value;

/**
 * Init this transform with a forward and reverse test value.
 * @param forward Assigned to the forward property.
 * @param reverse Assigned to the reverse property.
 */
- (id)initWithForward:(id)forward reverse:(id)reverse;

/** @name Conveniences */

/**
 * Conveniently returns a assert transform.
 * @param value Assigned to both forward and reverse.
 * @see initWithValue:
 */
+ (id)transformWithValue:(id)value;

/**
 * Conveniently returns a assert transform for integer values.
 * @param integer Boxed and assigned to both forward and reverse.
 * @see initWithValue:
 */
+ (id)transformWithInteger:(NSInteger)integer;

@end
