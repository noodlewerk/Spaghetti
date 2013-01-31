//
//  NWSXMLParser.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSParser.h"

/**
 * A parser based on libxml2.
 */
@interface NWSXMLParser : NWSParser

@property (nonatomic, assign) BOOL isFoldArray;
@property (nonatomic, assign) BOOL isFoldContent;
@property (nonatomic, copy) NSString *attributeKeyFormatter;
@property (nonatomic, copy) NSString *contentKey;

/**
 * NB: do not manipulate this instance; it's shared.
 */
+ (id)shared;

@end
