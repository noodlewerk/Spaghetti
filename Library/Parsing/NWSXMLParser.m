//
//  NWSXMLParser.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSXMLParser.h"
#import <libxml/parser.h>


@implementation NWSXMLParser

@synthesize isFoldArray, isFoldContent, attributeKeyFormatter, contentKey;

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
            NSString *nodeName = [NSString stringWithCString:(char *)node->name encoding:NSUTF8StringEncoding];
            
            // recursive call for child object (dictionary or string)
            id children = [self parseNode:node->children];
            
            for (xmlAttribute *attribute = (xmlAttribute *)((xmlElement *)node)->attributes; attribute; attribute = (xmlAttribute *)attribute->next) {
                // convert attribute name and value to NSString
                NSString *name = [NSString stringWithCString:(char *)attribute->name encoding:NSUTF8StringEncoding];
                xmlChar *str = xmlNodeGetContent((xmlNode *)attribute);
                NSString *value = [NSString stringWithCString:(char *)str encoding:NSUTF8StringEncoding];
                xmlFree(str);
                // add attribute (as prefixed child) to the children
                NSString *key = [NSString stringWithFormat:attributeKeyFormatter, name];
                if (!children) {
                    children = [NSMutableDictionary dictionaryWithObject:value forKey:key];
                } else if ([children isKindOfClass:NSDictionary.class]) {
                    [children setObject:value forKey:key];
                } else {
                    children = [NSMutableDictionary dictionaryWithObjectsAndKeys:children, contentKey, value, key, nil];
                }
            }
            
            if (children) {
                // add children to result
                if (!result) {
                    result = [NSMutableDictionary dictionaryWithObject:children forKey:nodeName];
                } else if([result isKindOfClass:NSDictionary.class]) {
                    id existing = [result objectForKey:nodeName];
                    if (!existing) {
                        if (isFoldArray) {
                            [result setObject:children forKey:nodeName];
                        } else {
                            [result setObject:[NSMutableArray arrayWithObject:children] forKey:nodeName];
                        }
                    } else if([existing isKindOfClass:NSArray.class]) {
                        [existing addObject:children];
                    } else {
                        [result setObject:[NSMutableArray arrayWithObjects:existing, children, nil] forKey:nodeName];
                    }
                } else {
                    result = [NSMutableDictionary dictionaryWithObjectsAndKeys:result, contentKey, children, nodeName, nil];
                }
            }
        } else if (node->type == XML_TEXT_NODE || node->type == XML_CDATA_SECTION_NODE) {
            // convert content to NSString
            xmlChar *str = xmlNodeGetContent(node);
            NSString *content = [[NSString stringWithCString:(const char *)str encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            xmlFree(str);
            // add content to result
            if (content.length) {
                if (!result) {
                    if (isFoldContent) {
                        result = content;
                    } else {
                        result = [NSMutableDictionary dictionaryWithObject:content forKey:contentKey];
                    }
                } else {
                    [result setObject:content forKey:contentKey];
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
