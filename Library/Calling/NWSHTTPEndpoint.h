//
//  NWSHTTPEndpoint.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSEndpoint.h"

/**
 * Endpoint to an HTTP resource. 
 * 
 * An NWSHTTPEndpoint provides the basis for retrieving information from an HTTP resource. At the minimum, the urlString which specifies the resource address must be set.
 *
 * @see NWSEndpoint
 */
@interface NWSHTTPEndpoint : NWSEndpoint

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, copy) NSString *method;

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key;
// TODO: - (void)setHeaders:(NSDictionary *)headers;
// TODO: - (void)removeAllHeaders;

@end
