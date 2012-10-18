//
//  NWService.h
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#pragma mark - Calling

#import "NWSBackend.h"
#import "NWSCall.h"
#import "NWSDialogue.h"
#import "NWSEndpoint.h"
#import "NWSSchedule.h"
#import "NWSOperation.h"
#import "NWSActivityIndicator.h"


#pragma mark - HTTP

#import "NWSHTTPCall.h"
#import "NWSHTTPConnection.h"
#import "NWSHTTPDialogue.h"
#import "NWSHTTPEndpoint.h"


#pragma mark - Mapping

#import "NWSMapping.h"
#import "NWSMappingContext.h"
#import "NWSMappingValidator.h"
#import "NWSPolicy.h"


#pragma mark - ObjectID

#import "NWSArrayObjectID.h"
#import "NWSManagedObjectID.h"
#import "NWSMemoryObjectID.h"
#import "NWSObjectID.h"


#pragma mark - ObjectType

#import "NWSClassObjectType.h"
#import "NWSEntityObjectType.h"
#import "NWSObjectType.h"


#pragma mark - Path

#import "NWSKeyPathPath.h"
#import "NWSPath.h"
#import "NWSSelfPath.h"
#import "NWSSingleKeyPath.h"
#import "NWSConstantValuePath.h"
#import "NWSCompositePath.h"
#import "NWSIndexPath.h"


#pragma mark - Parser

#import "NWSParser.h"
#import "NWSJSONParser.h"
#import "NWSXMLParser.h"
#import "NWSStringParser.h"


#pragma mark - Store

#import "NWSAmnesicStore.h"
#import "NWSBasicStore.h"
#import "NWSCoreDataStore.h"
#import "NWSMultiStore.h"
#import "NWSRecordingStore.h"
#import "NWSStore.h"
#import "NWSObjectReference.h"


#pragma mark - Transform

#import "NWSArrayTransform.h"
#import "NWSAssertTransform.h"
#import "NWSBlockTransform.h"
#import "NWSDateFormatterTransform.h"
#import "NWSIdentityTransform.h"
#import "NWSIDToObjectTransform.h"
#import "NWSMappingTransform.h"
#import "NWSTimeStampTransform.h"
#import "NWSTransform.h"
#import "NWSOrderKeyTransform.h"
#import "NWSCompositeTransform.h"
#import "NWSStringToNumberTransform.h"


#pragma mark - Test

#import "NWSTestCall.h"
#import "NWSTestDialogue.h"
#import "NWSTestEndpoint.h"

