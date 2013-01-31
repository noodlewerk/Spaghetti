//
//  NWSHTTPCall.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSCall.h"


@class NWSHTTPEndpoint, NWSStore, NWSMapping, NWSPath;

/**
 * An NWSCall over HTTP.
 */
@interface NWSHTTPCall : NWSCall <NSURLConnectionDelegate>

/**
 * URL string (host+path) to where the HTTP request will be sent. $-references will be substituted using the call's parameter dictionary.
 */
@property (nonatomic, copy) NSString *urlString;

/**
 * The concrete URL (without $-references)  to where the HTTP request will be sent.
 */
@property (nonatomic, strong, readonly) NSURL *resolvedURL;

/**
 * HTTP header key-value pairs. $-references will be substituted using the call's parameter dictionary.
 */
@property (nonatomic, strong, readonly) NSDictionary *headers;

@property (nonatomic, copy) NSString *method;

/**
 * Adds a key-value pair to the header. The value may contain $-references.
 * @param value String value for header key.
 * @param key String key.
 */
- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key;

/**
 * Adds a all key-value pairs to the header. The values may contain $-references.
 * @param headers Key-value pairs to be added to header dictionary.
 */
- (void)setHeaders:(NSDictionary *)headers;

@end
