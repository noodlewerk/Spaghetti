
Overview
================

One of the central focus point 

               +----------------+ +----------------+ +----------------+
    Service    |    Backend     | |    Schedule    | |    Operation   |
               +----------------+ +----------------+ +----------------+

               +----------------+ +----------------+ +----------------+
    Calling    |    Endpoint    | |      Call      | |   Dialogue     |
               +----------------+ +----------------+ +----------------+

               +----------------+ +----------------+ +----------------+
    Mapping    |     Mapping    | |      Path      | |    Transform   |
               +----------------+ +----------------+ +----------------+

               +----------------+ +----------------+ +----------------+
    Store      |      Store     | |    ObjectID    | |   ObjectType   |
               +----------------+ +----------------+ +----------------+

               +----------------+ +----------------+
    Utilities  |     Parser     | |      Path      |
               +----------------+ +----------------+


#### Service
At top we have a set loosly related classes that provide high-level functionality to manage and schedule operations.

#### Calling
The connection layer deals with creation and configuration of calls over the line. 

#### Mapping
Mapping is the process of transforming data from a generic dictionary format to objects of custom classes.

#### Store
Lala store

#### Utilities
The mapping and storing of data use a set of custom utilities that provide functionality not readily available in Apple's frameworks:

 * NWSParser provides a generic interface for turning data into a nested structure of dictionaries and array. Their output is recursively traversed during the mapping process.
 * NWSPath is an extension on the key path in KVC. It allows custom logic to be added to path definitions, for example to access array elements or provide constant values.
  