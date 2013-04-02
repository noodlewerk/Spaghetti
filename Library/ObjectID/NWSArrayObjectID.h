//
//  NWSArrayObjectID.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWSObjectID.h"

/**
 * A collection of object ids identifying is collection of objects.
 *
 * The array object id is mostly used to identify a to-many relation in a single object id. This allows for more flexible invocation of mapping functionality.
 *
 * @see NWSObjectID
 */
@interface NWSArrayObjectID : NWSObjectID

@property (nonatomic, strong) NSArray *identifiers;

- (id)initWithIdentifiers:(NSArray *)identifiers;

@end
