//
//  NWSParser.m
//  NWService
//
//  Created by leonard on 5/9/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSParser.h"
#import "NWSJSONKitParser.h"


@implementation NWSParser

- (id)parse:(NSData *)data // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

- (NSData *)serialize:(id)value // COV_NF_START
{
    NWLogWarn(@"Abstract method requires implementation");
    return nil;
} // COV_NF_END

+ (id)defaultParser
{
    return NWSJSONKitParser.shared;
}

@end
