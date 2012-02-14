//
//  NWSTestTools.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NWSTestTools : NSObject

+ (NSString *)jsonForSQON:(NSString *)singlyQuotedObjectNotation;
+ (id)objectForSQON:(NSString *)singlyQuotedObjectNotation;

@end
