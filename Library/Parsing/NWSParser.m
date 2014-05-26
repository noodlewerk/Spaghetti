//
//  NWSParser.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSParser.h"
#import "NWSJSONParser.h"
//#include "NWSLCore.h"


@implementation NWSParser

- (id)parse:(NSData *)data // COV_NF_START
{
    NWSLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (NSData *)serialize:(id)value // COV_NF_START
{
    NWSLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

+ (id)defaultParser
{
    return NWSJSONParser.shared;
}

@end
