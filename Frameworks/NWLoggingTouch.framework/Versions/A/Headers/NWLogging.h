//
//  NWLogging.h
//  NWLogging
//
//  Created by leonard on 6/25/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#ifndef _NWLOGGING_H_
#define _NWLOGGING_H_

#include "NWLCore.h"

#ifdef __OBJC__

#import "NWLFilePrinter.h"
#import "NWLMultiLogger.h"
#import "NWLPrinter.h"
#import "NWLTools.h"
#import "NWLLineLogger.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "NWLLogViewController.h"
#endif

#if TARGET_OS_MAC || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "NWLLogView.h"
#endif

#endif // __OBJC__

#endif // _NWLOGGING_H_
