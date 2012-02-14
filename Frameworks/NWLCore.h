//
//  NWLCore.h
//  NWLogging
//
//  Created by leonard on 4/25/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#include <string.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#import <CoreFoundation/CFString.h>

#ifdef __OBJC__
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#else // __OBJC__
#include <assert.h>
#endif // __OBJC__

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _NWLOGGING_H_
#define _NWLOGGING_H_


#pragma mark - Convenient logging operations
    
#ifdef NWL_LIB
    
#define NWL_LIB_STR NWL_STR(NWL_LIB)

/** Log directly. */
#define NWLog(_format, ...)                      NWLLogWithoutFilter(, NWL_LIB, _format, ##__VA_ARGS__)

/** Log on the 'dbug' tag. */
#define NWLogDbug(_format, ...)                  NWLLogWithFilter(dbug, NWL_LIB, _format, ##__VA_ARGS__)
    
/** Log on the 'info' tag. */
#define NWLogInfo(_format, ...)                  NWLLogWithFilter(info, NWL_LIB, _format, ##__VA_ARGS__)
    
/** Log on the 'warn' tag. */
#define NWLogWarn(_format, ...)                  NWLLogWithFilter(warn, NWL_LIB, _format, ##__VA_ARGS__)

/** Log on an 'warn' tag if the condition is false. */
#define NWLogWarnIfNot(_condition, _format, ...) do {if (!(_condition)) NWLLogWithFilter(warn, NWL_LIB, _format, ##__VA_ARGS__);} while (0)

/** Log on an error object on the 'warn' tag. */
#define NWLogWarnIfError(_error)                 do {if(_error) NWLLogWithFilter(warn, NWL_LIB, @"Caught: %@", _error);} while (0)
    
/** Log on a custom tag. */
#define NWLogTag(_tag, _format, ...)             NWLLogWithFilter(_tag, NWL_LIB, _format, ##__VA_ARGS__)
    
#else
    
#define NWL_LIB_STR NWL_STR()
#define NWLog(_format, ...)                      
#define NWLogDbug(_format, ...)
#define NWLogInfo(_format, ...)                  
#define NWLogWarn(_format, ...)                  
#define NWLogWarnIfNot(_condition, _format, ...) do {break; if (_condition) {}} while (0)
#define NWLogWarnIfError(_error)                       
#define NWLogTag(_tag, _format, ...)             
    
#endif

        
#pragma mark - The Good, the Bad and the Macro

#define NWL_STR(_a) NWL_STR_(_a)
#define NWL_STR_(_a) #_a

// Objective-C support
#ifdef __OBJC__
    #define _NWL_CFSTRING_(_str) ((__bridge CFStringRef)_str)
    #define _NWL_EXCEPTION_(_msg) [NSException raise:@"NWLogging" format:@"%@", _msg]
    #define _NWL_ASSERT_(_msg) NSCAssert1(NO, @"%@", _msg)
    #define _NWL_LOG_(_msg, _fmt, ...) NSLog(_fmt, ##__VA_ARGS__)
#else // __OBJC__
    #define _NWL_CFSTRING_(_str) CFSTR(_str)
    #define _NWL_EXCEPTION_(_msg) CFShow(_msg)
    #define _NWL_ASSERT_(_msg) assert(false)
    #define _NWL_LOG_(_msg, _fmt, ...) CFShow(_msg)
#endif // __OBJC__

// Misc helper macros
#define _NWL_FILE_ (strrchr((__FILE__), '/') + 1)    
    
/** Combines the format and parameters and prints it to stderr. */
#define NWLLogWithoutFilter(_tag, _lib, _fmt, ...) NWLLogWithoutFilter_(_tag, _lib, _fmt, ##__VA_ARGS__)
#define NWLLogWithoutFilter_(_tag, _lib, _fmt, ...) do {\
        NWLContext __context = {(#_tag), (#_lib), _NWL_FILE_, __LINE__, __PRETTY_FUNCTION__};\
        CFStringRef __message = CFStringCreateWithFormat(NULL, 0, _NWL_CFSTRING_(_fmt), ##__VA_ARGS__);\
        NWLForwardToPrinters(__context, __message);\
        CFRelease(__message);\
    } while (0)

/** Looks for a match and if so combines the format and parameters and performs the required action. */
#define NWLLogWithFilter(_tag, _lib, _fmt, ...) NWLLogWithFilter_(_tag, _lib, _fmt, ##__VA_ARGS__)
#define NWLLogWithFilter_(_tag, _lib, _fmt, ...) do {\
        NWLContext __context = {(#_tag), (#_lib), _NWL_FILE_, __LINE__, __PRETTY_FUNCTION__};\
        NWLAction __type = NWLActionForContext(__context);\
        if (__type) {\
            CFStringRef __message = CFStringCreateWithFormat(NULL, 0, _NWL_CFSTRING_(_fmt), ##__VA_ARGS__);\
            switch (__type) {\
                case kNWLAction_print: NWLForwardToPrinters(__context, __message); break;\
                case kNWLAction_break: NWLForwardToPrinters(__context, __message); kill(getpid(), SIGINT); break;\
                case kNWLAction_raise: _NWL_EXCEPTION_(__message); break;\
                case kNWLAction_assert: _NWL_ASSERT_(__message); break;\
                default: _NWL_LOG_(__message, _fmt, ##__VA_ARGS__); break;\
            }\
            CFRelease(__message);\
        }\
    } while (0)


/** Add a logging action for context properties. */
#define NWLAddFilter0(_action) NWLAddFilter0_(_action)
#define NWLAddFilter0_(_action) \
    NWLAddActionForContextProperties(kNWLProperty_none, NULL, kNWLProperty_none, NULL, kNWLProperty_none, NULL, (kNWLAction_##_action))

#define NWLAddFilter(_property1, _value1, _action) NWLAddFilter_(_property1, _value1, _action)
#define NWLAddFilter_(_property1, _value1, _action) \
    NWLAddActionForContextProperties((kNWLProperty_##_property1), (_value1), kNWLProperty_none, NULL, kNWLProperty_none, NULL, (kNWLAction_##_action))

#define NWLAddFilter2(_property1, _value1, _property2, _value2, _action) NWLAddFilter2_(_property1, _value1, _property2, _value2, _action)
#define NWLAddFilter2_(_property1, _value1, _property2, _value2, _action) \
    NWLAddActionForContextProperties((kNWLProperty_##_property1), (_value1), (kNWLProperty_##_property2), (_value2), kNWLProperty_none, NULL, (kNWLAction_##_action))

#define NWLAddFilter3(_property1, _value1, _property2, _value2, _property3, _value3, _action) NWLAddFilter3_(_property1, _value1, _property2, _value2, _property3, _value3, _action)
#define NWLAddFilter3_(_property1, _value1, _property2, _value2, _property3, _value3, _action) \
    NWLAddActionForContextProperties((kNWLProperty_##_property1), (_value1), (kNWLProperty_##_property2), (_value2), (kNWLProperty_##_property3), (_value3), (kNWLAction_##_action))


#pragma mark - Type definitions

/** Kinds of context properties to filter on */
typedef enum {
    kNWLProperty_none     = 0,
    kNWLProperty_tag      = 1,
    kNWLProperty_lib      = 2,
    kNWLProperty_file     = 3,
    kNWLProperty_function = 4,
    kNWLProperty_count    = 5,
} NWLProperty;

/** Kinds of actions to take when a log context matches properties */
typedef enum {
    kNWLAction_none   = 0,
    kNWLAction_print  = 1,
    kNWLAction_break  = 2,
    kNWLAction_raise  = 3,
    kNWLAction_assert = 4,
    kNWLAction_count  = 5,
} NWLAction;

/** The properties of a logging statement. */
typedef struct {
    const char *tag;
    const char *lib;
    const char *file;
    int line;
    const char *function;
} NWLContext;


#pragma mark - Core functions

/** Sends printing data to all printers. */
extern void NWLForwardToPrinters(NWLContext context, CFStringRef message);

/** Forward printing of line to printers, return true if added. */
extern int NWLAddPrinter(void(*)(NWLContext, CFStringRef, void *), void *info);

/** Remove a printer, return true if one was removed. */
extern int NWLRemovePrinter(void(*)(NWLContext, CFStringRef, void *), void *info);

/** Clear the printer list. */
extern void NWLRemoveAllPrinters(void);

/** Restore the default stderr printer. */
extern void NWLRestoreDefaultPrinters(void);

/** Formatter tailored for debugging, with format: "[hr:mn:sc:micros Library File:line] [tag] message", to stderr. */
extern void NWLDefaultPrinter(NWLContext context, CFStringRef message, void *info);

/** Tests context (like lib and file name) and returns the matching action. */
extern NWLAction NWLActionForContext(NWLContext context);

/** Activates and action for three context properties. */
extern int NWLAddActionForContextProperties(NWLProperty property1, const char *value1, NWLProperty property2, const char *value2, NWLProperty property3, const char *value3, NWLAction action);

/** Remove all actions for all properties. */
extern void NWLRemoveAllActions(void);

extern void NWLRestoreDefaultActions(void);

/** Reset the clock on log prints to 00:00:00. */
extern void NWLResetPrintClock(void);

/** Restore the clock on log prints to UTC time. */
extern void NWLRestorePrintClock(void);

/** Returns a human-readable summary of this logger. */
extern void NWLAboutString(char *buffer, int size);


#pragma mark - Convenient logging configuration

/** Activate the printing of all info statements. */
extern void NWLPrintInfo(void);

/** Activate the printing of all warn statements. */
extern void NWLPrintWarn(void);

/** Activate the printing of all dbug statements. */
extern void NWLPrintDbug(void);

/** Activate the printing of all statements on a custom tag. */
extern void NWLPrintTag(const char *tag);

/** Activate the printing of all statements. */
extern void NWLPrintAll(void);


/** Activate the printing of all info statements in one lib. */
extern void NWLPrintInfoInLib(const char *lib);

/** Activate the printing of all warn statements in one lib. */
extern void NWLPrintWarnInLib(const char *lib);

/** Activate the printing of all dbug statements in one lib. */
extern void NWLPrintDbugInLib(const char *lib);

/** Activate the printing of custom tag statements in one lib. */
extern void NWLPrintTagInLib(const char *tag, const char *lib);

/** Activate the printing of all statements in one lib. */
extern void NWLPrintAllInLib(const char *lib);


/** Activate printing of dbug statements in a file. */
extern void NWLPrintDbugInFile(const char *file);

/** Activate printing of dbug statements in a function, of the form: -[CLass parmeter:parmeter:]. */
extern void NWLPrintDbugInFunction(const char *function);


/** Activate breaking on all warn statements. */
extern void NWLBreakWarn(void);

/** Activate breaking on all warn statements in one lib. */
extern void NWLBreakWarnInLib(const char *lib);

/** Activate breaking of custom tag statements. */
extern void NWLBreakTag(const char *tag);

/** Activate breaking of custom tag statements in one lib. */
extern void NWLBreakTagInLib(const char *tag, const char *lib);


/** Deactivate actions of all info statements. */
extern void NWLClearInfo(void);

/** Deactivate actions of all warn statements. */
extern void NWLClearWarn(void);

/** Deactivate actions of all dbug statements. */
extern void NWLClearDbug(void);

/** Deactivate actions of custom tag statements. */
extern void NWLClearTag(const char *tag);

/** Deactivate actions of all statements in one lib. */
extern void NWLClearAllInLib(const char *lib);

/** Removes all actions for all filters. */
extern void NWLClearAll(void);

    
/** Log the interal state. */
extern void NWLAbout(void);


#endif // _NWLOGGING_H_
    
#ifdef __cplusplus
} // extern "C"
#endif
