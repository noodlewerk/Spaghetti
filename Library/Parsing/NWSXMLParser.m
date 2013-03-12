//
//  NWSXMLParser.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSXMLParser.h"
#import <libxml/parser.h>


@implementation NWSXMLParser

- (id)init
{
    self = [super init];
    if (self) {
        self.isFoldContent = YES;
        self.isFoldArray = YES;
        self.attributeKeyFormatter = @"_%@";
        self.contentKey = @"_";
    }
    return self;
}

- (id)parseNode:(xmlNode *)head
{
    id result = nil;
    
    for (xmlNode *node = head; node; node = node->next) {
        if (node->type == XML_ELEMENT_NODE) {
            // convert node name to NSString
            NSString *nodeName = @((char *)node->name);
            
            // recursive call for child object (dictionary or string)
            id children = [self parseNode:node->children];
            
            for (xmlAttribute *attribute = (xmlAttribute *)((xmlElement *)node)->attributes; attribute; attribute = (xmlAttribute *)attribute->next) {
                // convert attribute name and value to NSString
                NSString *name = @((char *)attribute->name);
                xmlChar *str = xmlNodeGetContent((xmlNode *)attribute);
                NSString *value = @((char *)str);
                xmlFree(str);
                // add attribute (as prefixed child) to the children
                NSString *key = [NSString stringWithFormat:_attributeKeyFormatter, name];
                if (!children) {
                    children = [NSMutableDictionary dictionaryWithObject:value forKey:key];
                } else if ([children isKindOfClass:NSDictionary.class]) {
                    children[key] = value;
                } else {
                    children = [NSMutableDictionary dictionaryWithObjectsAndKeys:children, _contentKey, value, key, nil];
                }
            }
            
            if (children) {
                // add children to result
                if (!result) {
                    result = [NSMutableDictionary dictionaryWithObject:children forKey:nodeName];
                } else if([result isKindOfClass:NSDictionary.class]) {
                    id existing = result[nodeName];
                    if (!existing) {
                        if (_isFoldArray) {
                            result[nodeName] = children;
                        } else {
                            result[nodeName] = [NSMutableArray arrayWithObject:children];
                        }
                    } else if([existing isKindOfClass:NSArray.class]) {
                        [existing addObject:children];
                    } else {
                        result[nodeName] = [NSMutableArray arrayWithObjects:existing, children, nil];
                    }
                } else {
                    result = [NSMutableDictionary dictionaryWithObjectsAndKeys:result, _contentKey, children, nodeName, nil];
                }
            }
        } else if (node->type == XML_TEXT_NODE || node->type == XML_CDATA_SECTION_NODE) {
            // convert content to NSString
            xmlChar *str = xmlNodeGetContent(node);
            NSString *content = [@((const char *)str) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            xmlFree(str);
            // add content to result
            if (content.length) {
                if (!result) {
                    if (_isFoldContent) {
                        result = content;
                    } else {
                        result = [NSMutableDictionary dictionaryWithObject:content forKey:_contentKey];
                    }
                } else {
                    result[_contentKey] = content;
                }
            }
        } else {
            NWLogWarn(@"Unknown node type: %i", node->type);
        }
    }
    
    return result;
}

- (id)parse:(NSData *)data
{
    id result = nil;
    xmlParserCtxtPtr context = xmlNewParserCtxt();
    if (context) {
        xmlDocPtr document = xmlParseMemory(data.bytes, (int)data.length);
        if (document) {
            result = [self parseNode:document->xmlRootNode];
            xmlFreeDoc(document);
        }
        xmlFreeParserCtxt(context);
    }
    return result;
}

+ (id)shared
{
    static NWSXMLParser *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NWSXMLParser alloc] init];
    });
    return result;
}

@end
