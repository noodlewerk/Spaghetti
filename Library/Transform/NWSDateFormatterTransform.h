//
//  NWSDateFormatterTransform.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSTransform.h"

/**
 * Transforms a date string into a date object, using an NSDateFormatter.
 *
 * @see NWSTimeStampTransform
 * @see NWSTransform
 */
@interface NWSDateFormatterTransform : NWSTransform

/**
 * The formatter applied to every input.
 */
@property (nonatomic, strong) NSDateFormatter *formatter;

/**
 * Inits by setting the formatter.
 * @param formatter The formatter applied to every input.
 */
- (id)initWithFormatter:(NSDateFormatter *)formatter;

/**
 * Inits a formatter with a format string.
 * @param string The format string fed to the date formatter.
 * @see initWithFormatter:
 */
- (id)initWithString:(NSString *)string;

- (id)initWithString:(NSString *)string localeString:(NSString *)locale;

@end
