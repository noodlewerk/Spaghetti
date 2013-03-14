
Spaghetti
=========

*A Cocoa framework for object mapping to and from not-so-RESTful web services.*


Introduction
------------
Connecting your app to a web server can be such a joy. Especially if that web server provides an API that was designed in cooperation with you and using the conventions of REST. Unfortunately this isn't always the case. Small design decision have big consequences for the implementation on the client side, leaving you with your super-RESTful framework that is a pain to connect to.

Spaghetti is a framework for connecting your app to a web server, but doesn't make too many assumptions on how RESTy that web server is. It consists of separate layers of abstraction that can be customized depending on the needs of the API. This makes it easy to connect to REST and less-than-horrible in other cases.


Features
--------
* Object mapping to and from Core Data, in-memory, or your custom object store.
* Support JSON, XML, and URL encoded data formats.
* Flexible key-path system for referencing attributes and relations.
* HTTP-independent endpoint and call definitions.
* Call scheduler.
* Built-in statistics, validation, logging and debugging tools.
* Example code and documentation.


Getting Started
---------------
Clone this repo and take a look at the demo code.


Overview
--------

               +----------------+ +----------------+ +----------------+
    Manage     |    Backend     | |    Schedule    | |    Operation   |
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
At top we have a set loosely related classes that provide high-level functionality to manage and schedule operations.

#### Calling
The connection layer deals with creation and configuration of calls over the line. 

#### Mapping
Mapping is the process of transforming data from a generic dictionary format to objects of custom classes.

#### Store

#### Utilities
The mapping and storing of data use a set of custom utilities that provide functionality not readily available in Apple's frameworks:

 * NWSParser provides a generic interface for turning data into a nested structure of dictionaries and array. Their output is recursively traversed during the mapping process.
 * NWSPath is an extension on the key path in KVC. It allows custom logic to be added to path definitions, for example to access array elements or provide constant values.
  
  
Build in XCode
--------------
The source comes with an XCode project file that should take care of building the library and running the demo app. To use Spaghetti in your project, you can build a static Framework using the `SpaghettiUniveral` target.


Documentation
-------------
Documentation generated and installed by running from the project root:

`appledoc -p Spaghetti -v 0.1 -c Noodlewerk --company-id com.noodlewerk -o . .`

See the [appledoc documentation](http://gentlebytes.com/appledoc/) for more info.


License
-------
Spaghetti is licensed under the terms of the BSD 2-Clause License, see the included LICENSE file.


Authors
-------
- [Noodlewerk](http://www.noodlewerk.com/)
- [Leonard van Driel](http://www.leonardvandriel.nl/)
- Michiel Boertjes
- Bruno Scheele
