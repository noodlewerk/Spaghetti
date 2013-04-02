//
//  NWSDateFormatterTransform.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSDateFormatterTransform.h"
#import "NWAbout.h"
#import "NWSMappingContext.h"
#include "NWLCore.h"


@implementation NWSDateFormatterTransform


- (id)initWithFormatter:(NSDateFormatter *)formatter
{
    self = [super init];
    if (self) {
        _formatter = formatter;
    }
    return self;
}

- (id)initWithString:(NSString *)string
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = string;
    return [self initWithFormatter:f];
}

- (id)initWithString:(NSString *)string localeString:(NSString *)locale
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = string;
    f.locale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
    return [self initWithFormatter:f];
}

#pragma mark - NWSTransform

- (NSDate *)transform:(NSString *)string context:(NWSMappingContext *)context
{
    if ([string isKindOfClass:NSString.class]) {
        NSDate *result = [_formatter dateFromString:string];
        if (!result) {
            NWLogWarn(@"Unable to parse string %@ (path:%@)", string, context.path);
        }
        return result;
    } else {
        NWLogWarn(@"Expecting NSString instead of %@ (path:%@)", string.class, context.path);
        return nil;
    }
}

- (NSString *)reverse:(NSDate *)date context:(NWSMappingContext *)context
{
    if ([date isKindOfClass:NSDate.class]) {
        NSString *result = [_formatter stringFromDate:date];
        if (!result) {
            NWLogWarn(@"Unable to format date %@ (path:%@)", date, context.path);
        }
        return result;
    } else {
        NWLogWarn(@"Expecting NSDate instead of %@ (path:%@)", date.class, context.path);
        return nil;
    }
}


#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p formatter:%@>", NSStringFromClass(self.class), self, _formatter];
}

- (NSString *)about:(NSString *)prefix
{
    return [@"date-formatter" about:prefix];
}

@end
