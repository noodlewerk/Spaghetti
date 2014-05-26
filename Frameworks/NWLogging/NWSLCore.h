//
//  NWSLCore.h
//  NWSLogging
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#include <string.h>
#import <CoreFoundation/CFString.h>

#ifdef __OBJC__
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#else // __OBJC__
#include <assert.h>
#endif // __OBJC__

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#ifndef _NWSLCORE_H_
#define _NWSLCORE_H_


#pragma mark - The Good, the Bad and the Macro

/** Macros for configuration stuff. */
#define NWSL_STR(_a) NWSL_STR_(_a)
#define NWSL_STR_(_a) #_a

#ifdef NWSL_LIB

#define NWSL_ACTIVE 1
#define NWSL_LIB_STR NWSL_STR(NWSL_LIB)

#else // NWSL_LIB

#if DEBUG
#define NWSL_ACTIVE 1
#else // DEBUG
#define NWSL_ACTIVE 0
#endif // DEBUG
#define NWSL_LIB_STR NULL

#endif // NWSL_LIB


#pragma mark - Common logging operations

/** Log directly, bypasses all filter and forwards directly to all printers. */
#define NWSLog(_format, ...)                      NWSLLogWithoutFilter(NULL, NWSL_LIB_STR, _format, ##__VA_ARGS__)

/** Log on the 'dbug' tag, which can be activated using NWSLPrintDbug(). */
#define NWSLogDbug(_format, ...)                  NWSLLogWithFilter("dbug", NWSL_LIB_STR, _format, ##__VA_ARGS__)

/** Log on the 'info' tag, which can be activated using NWSLPrintInfo(). */
#define NWSLogInfo(_format, ...)                  NWSLLogWithFilter("info", NWSL_LIB_STR, _format, ##__VA_ARGS__)
    
/** Log on the 'info' tag if the condition is true. */
#define NWSLogInfoIf(_condition, _format, ...)    do {if (_condition) NWSLogInfo(_format, ##__VA_ARGS__);} while (0)
    
/** Log on the 'warn' tag, which can be activated using NWSLPrintWarn(). */
#define NWSLogWarn(_format, ...)                  NWSLLogWithFilter("warn", NWSL_LIB_STR, _format, ##__VA_ARGS__)

/** Log on an 'warn' tag if the condition is false. */
#define NWSLogWarnIfNot(_condition, _format, ...) do {if (!(_condition)) NWSLogWarn(_format, ##__VA_ARGS__);} while (0)

/** Log error description on the 'warn' tag if error is not nil. */
#define NWSLogWarnIfError(_error)                 NWSLogWarnIfNot(!(_error), @"Caught: %@", (_error))

/** Log on a custom tag, which can be activated using NWSLPrintTag(tag). */
#define NWSLogTag(_tag, _format, ...)             NWSLLogWithFilter((#_tag), NWSL_LIB_STR, _format, ##__VA_ARGS__)

/** Convenient assert and error macros. */
#define NWAssert(_condition)                     NWSLogWarnIfNot((_condition), @"Expected true condition '"#_condition@"' in %s:%i", _NWSL_FILE_, __LINE__)
#define NWAssertMainThread()                     NWSLogWarnIfNot(_NWSL_MAIN_THREAD_, @"Expected running on main thread in %s:%i", _NWSL_FILE_, __LINE__)
#define NWAssertQueue(_queue,_label)             NWSLogWarnIfNot(strcmp(dispatch_queue_get_label(_queue)?:"",#_label)==0, @"Expected running on '%s', not on '%s' in %s:%i", #_label, dispatch_queue_get_label(_queue), _NWSL_FILE_, __LINE__)
#define NWParameterAssert(_condition)            NWSLogWarnIfNot((_condition), @"Expected parameter: '"#_condition@"' in %s:%i", _NWSL_FILE_, __LINE__)
#define NWError(_error)                          do {NWSLogWarnIfNot(!(_error), @"Caught: %@", (_error)); _error = nil;} while (0)


#pragma mark - Logging macros

// ARC helper
#if __has_feature(objc_arc)
#define _NWSL_BRIDGE_ __bridge
#else // __has_feature(objc_arc)
#define _NWSL_BRIDGE_
#endif // __has_feature(objc_arc)

// C/Objective-C support
#ifdef __OBJC__
#define _NWSL_CFSTRING_(_str) ((_NWSL_BRIDGE_ CFStringRef)_str)
#define _NWSL_MAIN_THREAD_ [NSThread isMainThread]
#else // __OBJC__
#define _NWSL_CFSTRING_(_str) CFSTR(_str)
#define _NWSL_MAIN_THREAD_ (dispatch_get_main_queue() == dispatch_get_current_queue())
#endif // __OBJC__

// Misc helper macros
#define _NWSL_FILE_ (strrchr((__FILE__), '/') + 1)
#define NWSL_CALLER ({NSString*__line=NSThread.callStackSymbols[1];NSRange r=[__line rangeOfString:@"0x"];[NSString stringWithFormat:@"<%@>",r.length?[__line substringFromIndex:r.location]:__line];})
#define NWSL_STACK(__a) ({NSArray*lines=NSThread.callStackSymbols;[lines subarrayWithRange:NSMakeRange(0,__a<lines.count?__a:lines.count)];})

#define NWSLLogWithoutFilter(_tag, _lib, _fmt, ...) NWSLLogWithoutFilter_(_tag, _lib, _fmt, ##__VA_ARGS__)
#define NWSLLogWithFilter(_tag, _lib, _fmt, ...) NWSLLogWithFilter_(_tag, _lib, _fmt, ##__VA_ARGS__)
    
#if NWSL_ACTIVE
#define NWSLLogWithoutFilter_(_tag, _lib, _fmt, ...) NWSLForwardWithoutFilter((NWSLContext){_tag, _lib, _NWSL_FILE_, __LINE__, __PRETTY_FUNCTION__, NWSLTime()}, _NWSL_CFSTRING_(_fmt), ##__VA_ARGS__)
#define NWSLLogWithFilter_(_tag, _lib, _fmt, ...) NWSLForwardWithFilter((NWSLContext){_tag, _lib, _NWSL_FILE_, __LINE__, __PRETTY_FUNCTION__, NWSLTime()}, _NWSL_CFSTRING_(_fmt), ##__VA_ARGS__)
#else // NWSL_ACTIVE
#define NWSLLogWithoutFilter_(_tag, _lib, _fmt, ...) do {} while (0)
#define NWSLLogWithFilter_(_tag, _lib, _fmt, ...) do {} while (0)
#endif // NWSL_ACTIVE


#pragma mark - Type definitions

/** Types of context properties to filter on */
typedef enum {
    kNWSLProperty_none     = 0,
    kNWSLProperty_tag      = 1,
    kNWSLProperty_lib      = 2,
    kNWSLProperty_file     = 3,
    kNWSLProperty_function = 4,
    kNWSLProperty_count    = 5,
} NWSLProperty;

/** Types of actions to take when a log context matches properties */
typedef enum {
    kNWSLAction_none   = 0,
    kNWSLAction_print  = 1,
    kNWSLAction_break  = 2,
    kNWSLAction_count  = 3,
} NWSLAction;

/** The properties of a logging statement. */
typedef struct {
    const char *tag;
    const char *lib;
    const char *file;
    int line;
    const char *function;
    double time;
} NWSLContext;


#pragma mark - Configuration

/** Forwards context and formatted log line to printers. */
extern void NWSLForwardWithoutFilter(NWSLContext context, CFStringRef format, ...) CF_FORMAT_FUNCTION(2,3);

/** Looks for the best-matching filter and performs the associated action. */
extern void NWSLForwardWithFilter(NWSLContext context, CFStringRef format, ...) CF_FORMAT_FUNCTION(2,3);

/** Forward printing of line to printers, return true if added. */
extern int NWSLAddPrinter(const char *name, void(*)(NWSLContext, CFStringRef, void *), void *info);

/** Remove a printer, returns info of the printer. */
extern void * NWSLRemovePrinter(const char *name);

/** Clear the printer list. */
extern void NWSLRemoveAllPrinters(void);

/** Restore the default stderr printer. */
extern void NWSLRestoreDefaultPrinters(void);

/** Add the default stderr printer. */
extern void NWSLAddDefaultPrinter(void);

/** Formatter tailored for debugging, with format: "[hr:mn:sc:micros Library File:line] [tag] message", to stderr. */
extern void NWSLStderrPrinter(NWSLContext context, CFStringRef message, void *info);


/** Tests context (like lib and file name) and returns the matching action. */
extern NWSLAction NWSLMatchingActionForContext(NWSLContext context);

/** Activates and action for these filter properties. */
extern int NWSLAddFilter(const char *tag, const char *lib, const char *file, const char *function, NWSLAction action);

/** Finds filter that machtes these filter properties and returns its action. */
extern NWSLAction NWSLHasFilter(const char *tag, const char *lib, const char *file, const char *function);

/** Remove all filters that are included by these filter properties. */
extern int NWSLRemoveMatchingFilters(const char *tag, const char *lib, const char *file, const char *function);

/** Remove all actions for all properties. */
extern void NWSLRemoveAllFilters(void);

/** Restore the default print-on-warn filter. */
extern void NWSLRestoreDefaultFilters(void);

/** Add the default print-on-warn filter. */
extern void NWSLAddDefaultFilter(void);


/** Reset the clock on log prints to 00:00:00. */
extern void NWSLResetPrintClock(void);

/** Offset the clock on log prints with seconds. */
extern void NWSLOffsetPrintClock(double seconds);

/** Restore the clock on log prints to UTC time. */
extern void NWSLRestorePrintClock(void);

/** Seconds since epoch. */
extern double NWSLTime(void);

/** Provides clock values, returns time since epoch or since reset. */
extern void NWSLClock(double time, int *hour, int *minute, int *second, int *micro);

/** Returns a human-readable summary of this logger, returns the length of the about text excluding the null byte independent of 'size'. */
extern int NWSLAboutString(char *buffer, int size);

/** Log the internal state. */
extern void NWSLogAbout(void);


/** Restore all internal state, including default printers, default filters, and default clock. **/
extern void NWSLRestore(void);


#pragma mark - Common Configuration

/** Activate the printing of all log statements. */
extern void NWSLPrintInfo(void);
extern void NWSLPrintWarn(void);
extern void NWSLPrintDbug(void);
extern void NWSLPrintTag(const char *tag);
extern void NWSLPrintAll(void);

/** Activate the printing in one lib. */
extern void NWSLPrintInfoInLib(const char *lib);
extern void NWSLPrintWarnInLib(const char *lib);
extern void NWSLPrintDbugInLib(const char *lib);
extern void NWSLPrintTagInLib(const char *tag, const char *lib);
extern void NWSLPrintAllInLib(const char *lib);
    
#define NWSLPrintInfoInThisLib()      NWSLPrintInfoInLib(NWSL_LIB_STR)
#define NWSLPrintWarnInThisLib()      NWSLPrintWarnInLib(NWSL_LIB_STR)
#define NWSLPrintDbugInThisLib()      NWSLPrintDbugInLib(NWSL_LIB_STR)
#define NWSLPrintTagInThisLib(__tag)  NWSLPrintTagInLib(__tag, NWSL_LIB_STR)
#define NWSLPrintAllInThisLib()       NWSLPrintAllInLib(NWSL_LIB_STR)
#define NWSLPrintOnlyInThisLib()      do {NWSLRemoveAllFilters();NWSLPrintAllInLib(NWSL_LIB_STR);} while (0)
    
/** Activate printing in a file or function. */
extern void NWSLPrintDbugInFile(const char *file);
extern void NWSLPrintAllInFile(const char *file);
extern void NWSLPrintDbugInFunction(const char *function);
    
#define NWSLPrintDbugInThisFile()     NWSLPrintDbugInFile(_NWSL_FILE_)
#define NWSLPrintAllInThisFile()      NWSLPrintAllInFile(_NWSL_FILE_)
#define NWSLPrintDbugInThisFunction() NWSLPrintDbugInFunction(__PRETTY_FUNCTION__)
#define NWSLPrintOnlyInThisFile()     do {NWSLRemoveAllFilters();NWSLPrintAllInFile(_NWSL_FILE_);} while (0)
#define NWSLPrintOnlyInThisFunction() do {NWSLRemoveAllFilters();NWSLPrintAllInFunction(__PRETTY_FUNCTION__);} while (0)

/** Activate breaking. */
extern void NWSLBreakWarn(void);
extern void NWSLBreakWarnInLib(const char *lib);
extern void NWSLBreakTag(const char *tag);
extern void NWSLBreakTagInLib(const char *tag, const char *lib);

#define NWSLBreakWarnInThisLib()       NWSLBreakWarnInLib(NWSL_LIB_STR)
#define NWSLBreakTagInThisLib(__tag)   NWSLBreakTagInLib(__tag, NWSL_LIB_STR)

/** Deactivate actions. */
extern void NWSLClearInfo(void);
extern void NWSLClearWarn(void);
extern void NWSLClearDbug(void);
extern void NWSLClearTag(const char *tag);
extern void NWSLClearAllInLib(const char *lib);
extern void NWSLClearAll(void);
    
#define NWSLClearAllInThisLib()        NWSLClearAllInLib(NWSL_LIB_STR)
    

#pragma mark - Debugging

void NWSLBreakInDebugger(void);

/** Print internal state info to stderr. */
extern void NWSLDump(void);
extern void NWSLDumpFlags(int active, const char *lib, int debug, const char *file, int line, const char *function);
extern void NWSLDumpConfig(void);
#if DEBUG
#define NWSL_DEBUG 1
#else // DEBUG
#define NWSL_DEBUG 0
#endif // DEBUG
#define NWSLDump() do {NWSLDumpFlags(NWSL_ACTIVE, NWSL_LIB_STR, NWSL_DEBUG, _NWSL_FILE_, __LINE__, __PRETTY_FUNCTION__);NWSLDumpConfig();} while (0)


#endif // _NWSLCORE_H_

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus
