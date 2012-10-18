
NWService
=========

*NWService is a client-side connection and mapping layer between client and server, for example to connect a RESTful json from a server to Core Data on the client.*


Introduction
------------
... Features, Getting started, Design, FAQ


Overview
--------

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
  
  
Build in XCode
--------------
The source comes with an XCode 4 project file that should take care of building the library and running the demo app. To use NWService in your project, you can link to its static library, or directly include those source files needed. The latter does require your project to use the LLVM 3.0 compiler with ARC.


Documentation
-------------
Documentation generated and installed by running from the project root:

`appledoc -p NWService -v 0.1 -c Noodlewerk --company-id com.noodlewerk -o . .`

See the [appledoc documentation](http://gentlebytes.com/appledoc/) for more info.


License
-------
NWLogging is licensed under the terms of the BSD 2-Clause License, see the included LICENSE file.


Authors
-------
- [Noodlewerk](http://www.noodlewerk.com/)
- [Leonard van Driel](http://www.leonardvandriel.nl/)
- Michiel Boertjes
- Bruno Scheele
