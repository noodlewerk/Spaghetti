//
//  NWSMapsService.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWService.h"

@interface NWSMapsRoute : NSObject
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *copyrights;
@end

@interface NWSMapsResponse : NSObject
@property (nonatomic, strong) NWSMapsRoute *route;
@property (nonatomic, copy) NSString *status;
@end

@interface NWSMapsService : NSObject

+ (NWSBackend *)backend;

@end
