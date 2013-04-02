//
//  NWHTTP.h
//  NWTools
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NWHTTP : NSObject

+ (void)addFormDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request;
+ (void)addMultipartDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request;

+ (NSData *)multipartDataWithParameters:(NSDictionary *)parameters boundary:(NSString **)boundary;
+ (NSString *)urlWithBase:(NSString *)root path:(NSArray *)path query:(NSDictionary *)query;
+ (NSString *)joinQueryWithDictionary:(NSDictionary *)dictionary;
+ (NSString *)joinPathWithArray:(NSArray *)array;
+ (NSDictionary *)splitQueryWithString:(NSString *)string;

+ (NSString *)escape:(NSString *)string;
+ (NSString *)unescape:(NSString *)string;

@end
