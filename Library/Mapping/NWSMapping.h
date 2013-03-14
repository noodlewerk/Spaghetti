//
//  NWSMapping.h
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@class NWSObjectID, NWSMappingContext, NWSTransform, NWSObjectType, NWSPath, NWSStore, NWSPolicy;


/**
 * An entry in a mapping, which addresses a specific attribute or relation in both the element and the object and a transform between these. This object is primarily a sub-container used by a mapping to store each individual mapping task.
 *
 * @see NWSMapping
 */
@interface NWSMappingEntry : NSObject

@property (nonatomic, strong, readonly) NWSPath *elementPath;
@property (nonatomic, strong, readonly) NWSPath *objectPath;
@property (nonatomic, strong, readonly) NWSTransform *transform;
@property (nonatomic, strong, readonly) NWSPolicy *policy;

@end



/**
 * A mapping dictates how an arbitrary element (usually a dictionary) should be mapped to an object.
 *
 * The mapping contains information on what type of object it should be mapping to, allowing this object to be fetched or created. It also contains the attributes and relations that should be mapped and which of these are primary.
 *
 * @see NWSObjectType
 * @see NWSTransform
 * @see NWSStore
 * @see NWSMappingValidator
 */
@interface NWSMapping : NSObject <NSCopying>


/** @name Configuring mapping */

/**
 * Type of the object that will be mapped onto.
 * 
 * This type is used when doing an object lookup based on a primary key, and used when creating a new instance to map onto.
 * @see NWSStore
 */
@property (nonatomic, strong) NWSObjectType *objectType;

/**
 * Sets the type of object used with this mapping.
 * 
 * This indicates that the type is based on a Objective-C class.
 * @param className Name of a Objective-C class.
 * @see objectType
 * @see NWSClassObjectType
 */
- (void)setObjectClassName:(NSString *)className;

- (void)setObjectClass:(Class)clas;

/**
 * Sets the type of object used with this mapping.
 * 
 * This indicates that the type is based on a Core Data entity description.
 * @param entityName Name of a Core Data entity.
 * @param model The object model in which this entity resides.
 * @see NWSEntityObjectType
 */
- (void)setObjectEntityName:(NSString *)entityName model:(NSManagedObjectModel *)model;

- (void)setObjectEntity:(NSEntityDescription *)entity;


/** @name Accessing entries */

/**
 * A collection of mapping entries that represent object attributes.
 * @see NWSMappingEntry
 */
@property (nonatomic, strong, readonly) NSArray *attributes;

/**
 * A collection of mapping entries that represent object relations.
 * @see NWSMappingEntry
 */
@property (nonatomic, strong, readonly) NSArray *relations;

/**
 * A collection of mapping entries that represent primary attributes.
 * @see NWSMappingEntry
 */
@property (nonatomic, strong, readonly) NSArray *primaries;


/** @name Adding attribute entries */

/**
 * Adds a mapping entry to the attributes collection and optionally to the primaries collection.
 * @param entry An attribute entry.
 * @param isPrimary If YES, this entry will be added to both attributes and primaries.
 * @see attributes
 * @see primaries
 * @see NWSMappingEntry
 */
- (void)addAttributeEntry:(NWSMappingEntry *)entry isPrimary:(BOOL)isPrimary;

/**
 * Adds an attribute entry with one path for both the element and the object.
 * @param path Path to an attribute in both the element and the object.
 * @see addAttributeEntry:isPrimary:
 */
- (void)addAttributeWithPath:(NSString *)path;

/**
 * Adds an attribute entry with a path for the element and one for the object.
 * @param elementPath Path to an attribute in the element.
 * @param objectPath Path to an attribute in the object.
 * @see addAttributeEntry:isPrimary:
 */
- (void)addAttributeWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath;

/**
 * Adds an attribute entry with a path for the element and one for the object, including a transform.
 * @param elementPath Path to an attribute in the element.
 * @param objectPath Path to an attribute in the object.
 * @param transform The transform applied to the element attribute.
 * @see addAttributeEntry:isPrimary:
 */
- (void)addAttributeWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath transform:(NWSTransform *)transform;

/**
 * Adds an attribute entry with one path for both the element and the object.
 * @param path Path to an attribute in both the element and the object.
 * @param isPrimary If YES, this entry will be added to both attributes and primaries.
 * @see addAttributeEntry:isPrimary:
 */
- (void)addAttributeWithPath:(NSString *)path isPrimary:(BOOL)isPrimary;

/**
 * Adds an attribute entry with a path for the element and one for the object.
 * @param elementPath Path to an attribute in the element.
 * @param objectPath Path to an attribute in the object.
 * @param isPrimary If YES, this entry will be added to both attributes and primaries.
 * @see addAttributeEntry:isPrimary:
 */
- (void)addAttributeWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath isPrimary:(BOOL)isPrimary;

/**
 * Adds an attribute entry with a path for the element and one for the object, including a transform.
 * @param elementPath Path to an attribute in the element.
 * @param objectPath Path to an attribute in the object.
 * @param transform The transform applied to the element attribute.
 * @param isPrimary If YES, this entry will be added to both attributes and primaries.
 * @see addAttributeEntry:isPrimary:
 */
- (void)addAttributeWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath transform:(NWSTransform *)transform isPrimary:(BOOL)isPrimary;

/**
 * Adds an attribute entry with only a path for the object and no particular path in the element.
 * 
 * This allows assignment of object attributes that do not have a corresponding element attribute, like order key or a constant value. In this case the transform can ignore its input value, which will be the element, and generates an output value by itself.
 * @param objectPath Path to an attribute in the object.
 * @param transform The transform that provides the object attribute value.
 * @param isPrimary If YES, this entry will be added to both attributes and primaries.
 * @see addAttributeEntry:isPrimary:
 * @see NWSOrderKeyTransform
 */
- (void)addAttributeWithObjectPath:(NSString *)objectPath transform:(NWSTransform *)transform isPrimary:(BOOL)isPrimary;


/** @name Adding relation entries */

/**
 * Adds a mapping entry to the relations collection.
 * @param entry A relation entry.
 * @see relations
 * @see NWSMappingEntry
 */
- (void)addRelationEntry:(NWSMappingEntry *)entry;

/**
 * Adds an relation entry with one path for both the element and the object, including a mapping.
 * 
 * The element path is expected to point to a sub-element, which will be mapped and stored in the relation.
 * @param path Path to a relation in both the element and the object.
 * @param mapping The mapping for the sub-element.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 */
- (void)addRelationWithPath:(NSString *)path mapping:(NWSMapping *)mapping policy:(NWSPolicy *)policy;

/**
 * Adds an relation entry with one path for both the element and the object, including an class name and primary key.
 * 
 * The element path is expected to point to a primary value that will be used to look-up or create an object. This can be useful when a relation is stored in the element by the primary value, e.g. `"object_id":1`, instead of the object data itself.
 * @param path Path to a relation in both the element and the object.
 * @param className The name of the class in this relation.
 * @param primary The primary attribute in the object.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 * @see NWSIDToObjectTransform
 */
- (void)addRelationWithPath:(NSString *)path className:(NSString *)className primary:(NSString *)primary policy:(NWSPolicy *)policy;

/**
 * Adds an relation entry with one path for both the element and the object, including an entity name and primary key.
 * 
 * The element path is expected to point to a primary value that will be used to look-up or create an object. This can be useful when a relation is stored in the element by the primary value, e.g. `"object_id":1`, instead of the object data itself.
 * @param path Path to a relation in both the element and the object.
 * @param entityName The name of the entity in this relation.
 * @param model The model this entity resides in.
 * @param primary The primary attribute in the object.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 * @see NWSIDToObjectTransform
 */
- (void)addRelationWithPath:(NSString *)path entityName:(NSString *)entityName model:(NSManagedObjectModel *)model primary:(NSString *)primary policy:(NWSPolicy *)policy;

/**
 * Adds an relation entry with one path for both the element and the object, including a transform.
 * @param path Path to a relation in both the element and the object.
 * @param transform The transform applied to the element relation.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 */
- (void)addRelationWithPath:(NSString *)path transform:(NWSTransform *)transform policy:(NWSPolicy *)policy;

/**
 * Adds an relation entry with a path for the element and one for the object, including mapping.
 * 
 * The element path is expected to point to a sub-element, which will be mapped and stored in the relation.
 * @param elementPath Path to a primary value in the element.
 * @param objectPath Path to a relation in the object.
 * @param mapping The mapping for the sub-element.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 */
- (void)addRelationWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath mapping:(NWSMapping *)mapping policy:(NWSPolicy *)policy;

/**
 * Adds an relation entry with a path for the element and one for the object, including an class name and primary key.
 * 
 * The element path is expected to point to a primary value that will be used to look-up or create an object. This can be useful when a relation is stored in the element by the primary value, e.g. `"object_id":1`, instead of the object data itself.
 * @param elementPath Path to a primary value in the element.
 * @param objectPath Path to a relation in the object.
 * @param className The name of the class in this relation.
 * @param primary The primary attribute in the object.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 * @see NWSIDToObjectTransform
 */
- (void)addRelationWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath className:(NSString *)className primary:(NSString *)primary policy:(NWSPolicy *)policy;

/**
 * Adds an relation entry with a path for the element and one for the object, including an entity name and primary key.
 * 
 * The element path is expected to point to a primary value that will be used to look-up or create an object. This can be useful when a relation is stored in the element by the primary value, e.g. `"object_id":1`, instead of the object data itself.
 * @param elementPath Path to a primary value in the element.
 * @param objectPath Path to a relation in the object.
 * @param entityName The name of the entity in this relation.
 * @param model The model this entity resides in.
 * @param primary The primary attribute in the object.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 * @see NWSIDToObjectTransform
 */
- (void)addRelationWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath entityName:(NSString *)entityName model:(NSManagedObjectModel *)model primary:(NSString *)primary policy:(NWSPolicy *)policy;

/**
 * Adds an relation entry with a path for the element and one for the object, including a transform.
 * @param elementPath Path to a relation in the element.
 * @param objectPath Path to a relation in the object.
 * @param transform The transform applied to the element relation.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 */
- (void)addRelationWithElementPath:(NSString *)elementPath objectPath:(NSString *)objectPath transform:(NWSTransform *)transform policy:(NWSPolicy *)policy;

/**
 * Adds an relation entry with only a path for the object and no particular path in the element.
 * 
 * This allows assignment of object relations that do not have a corresponding element relation. In this case the transform can ignore its input value, which will be the element, and generates an output value by itself.
 * @param objectPath Path to a relation in the object.
 * @param transform The transform that provides the object relation value.
 * @param policy The relation set policy.
 * @see addRelationEntry:
 */
- (void)addRelationWithObjectPath:(NSString *)objectPath transform:(NWSTransform *)transform policy:(NWSPolicy *)policy;


/** @name Mapping elements and objects */

/**
 * Applies this mapping onto an element, like a dictionary or array.
 * @param element A data element as input.
 * @param context The context of the current mapping operation.
 * @see mapElement:store:
 * @see mapIdentifier:context:
 */
- (NWSObjectID *)mapElement:(NSObject *)element context:(NWSMappingContext *)context;

/**
 * Applies this mapping onto an element, like a dictionary or array.
 * @param element A data element as input for the transform.
 * @param store The store where the outcome will be stored.
 * @see mapElement:context:
 * @see mapIdentifier:store:
 */
- (NWSObjectID *)mapElement:(NSObject *)element store:(NWSStore *)store;

- (id)objectWithMapElement:(NSObject *)element store:(NWSStore *)store;

/**
 * Reverses this mapping on an object.
 * @param identifier The object to be inverse-transformed.
 * @param context The context of the current mapping operation.
 * @see mapIdentifier:store:
 * @see mapElement:context:
 */
- (NSObject *)mapIdentifier:(NWSObjectID *)identifier context:(NWSMappingContext *)context;

/**
 * Reverses this mapping on an object.
 * @param identifier The object to be inverse-transformed.
 * @param store The store in which the object resides.
 * @see mapIdentifier:context:
 * @see mapElement:store:
 */
- (NSObject *)mapIdentifier:(NWSObjectID *)identifier store:(NWSStore *)store;

- (id)mapIdentifierWithObject:(id)object store:(NWSStore *)store;

/**
 * Disposes all relations to ensure no retain cycles exist though mapping transforms in these relations.
 */
- (void)breakCycles;

@end
