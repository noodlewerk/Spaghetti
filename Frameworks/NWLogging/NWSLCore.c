//
//  NWSLCore.m
//  NWSLogging
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSLCore.h"
#include <stdio.h>
#include <string.h>
#include <sys/uio.h>
#include <sys/sysctl.h>
#include <signal.h>
#include <unistd.h>
#include <math.h>
#import <CoreFoundation/CFDate.h>

#pragma mark - Constants and statics

static const int kNWSLFilterListSize = 16;
static const int kNWSLPrinterListSize = 8;

typedef struct {
    const char *properties[kNWSLProperty_count];
    NWSLAction action;
} NWSLFilter;

typedef struct {
    int count;
    NWSLFilter elements[kNWSLFilterListSize];
} NWSLFilterList;

typedef struct {
    const char *name;
    void(*func)(NWSLContext, CFStringRef, void *);
    void *info;
} NWSLPrinter;

typedef struct {
    int count;
    NWSLPrinter elements[kNWSLPrinterListSize];
} NWSLPrinterList;

#define NWSLDefaultPrinterFunction NWSLStderrPrinter
#define NWSLDefaultPrinterName "default"
#define NWSLDefaultFilterTag "warn"
#define NWSLDefaultFilterAction kNWSLAction_print
static NWSLFilterList NWSLFilters = {1, {NULL, NWSLDefaultFilterTag, NULL, NULL, NULL, NWSLDefaultFilterAction}};
static NWSLPrinterList NWSLPrinters = {1, {NWSLDefaultPrinterName, NWSLDefaultPrinterFunction, NULL}};
static CFTimeInterval NWSLTimeOffset = 0;


#pragma mark - Printing

void NWSLForwardToPrinters(NWSLContext context, CFStringRef message) {
    for (int i = 0; i < NWSLPrinters.count; i++) {
        NWSLPrinter *printer = &NWSLPrinters.elements[i];
        void(*func)(NWSLContext, CFStringRef, void *) = printer->func;
        func(context, message, printer->info);
    }
}

void NWSLForwardWithoutFilter(NWSLContext context, CFStringRef format, ...) {
    va_list arglist;
    va_start(arglist, format);
    CFStringRef message = CFStringCreateWithFormatAndArguments(NULL, 0, format, arglist);
    va_end(arglist);
    NWSLForwardToPrinters(context, message);
    CFRelease(message);
}

void NWSLForwardWithFilter(NWSLContext context, CFStringRef format, ...) {
    NWSLAction type = NWSLMatchingActionForContext(context);
    if (type) {
        va_list arglist;
        va_start(arglist, format);
        CFStringRef message = CFStringCreateWithFormatAndArguments(NULL, 0, format, arglist);
        va_end(arglist);
        switch (type) {
            case kNWSLAction_print: NWSLForwardToPrinters(context, message); break;
            case kNWSLAction_break: NWSLForwardToPrinters(context, message); NWSLBreakInDebugger(); break;
            default: CFShow(message); break;
        }
        CFRelease(message);
    }
}

int NWSLAddPrinter(const char *name, void(*func)(NWSLContext, CFStringRef, void *), void *info) {
    int count = NWSLPrinters.count;
    if (count < kNWSLPrinterListSize) {
        NWSLPrinter printer = {name, func, info};
        NWSLPrinters.elements[count] = printer;
        NWSLPrinters.count = count + 1;
        return true;
    }
    return false;
}

void * NWSLRemovePrinter(const char *name) {
    for (int i = NWSLPrinters.count - 1; i >= 0; i--) {
        NWSLPrinter *p = &NWSLPrinters.elements[i];
        const char *n = p->name;
        if (n == name || (n && name && !strcasecmp(n, name))) {
            int count = NWSLPrinters.count;
            if (count > 0) {
                void *info = p->info;
                NWSLPrinters.count = count - 1;
                NWSLPrinters.elements[i] = NWSLPrinters.elements[count - 1];
                return info;
            }
        }
    }
    return NULL;
}

void NWSLRemoveAllPrinters(void) {
    NWSLPrinters.count = 0;
}

void NWSLAddDefaultPrinter(void) {
    NWSLAddPrinter(NWSLDefaultPrinterName, NWSLDefaultPrinterFunction, NULL);
}

void NWSLRestoreDefaultPrinters(void) {
    NWSLRemoveAllPrinters();
    NWSLAddDefaultPrinter();
}

void NWSLStderrPrinter(NWSLContext context, CFStringRef message, void *info) {
    // init io vector
    struct iovec iov[16];
    int i = 0;
    iov[i].iov_base = "[";
    iov[i++].iov_len = 1;

    // add time
    int hour = 0, minute = 0, second = 0, micro = 0;
    NWSLClock(context.time, &hour, &minute, &second, &micro);
    char timeBuffer[16];
    int timeLength = snprintf(timeBuffer, sizeof(timeBuffer), "%02i:%02i:%02i.%06i", hour, minute, second, micro);
    iov[i].iov_base = timeBuffer;
    iov[i++].iov_len = sizeof(timeBuffer) - 1 < timeLength ? sizeof(timeBuffer) - 1 : timeLength;

    // add context
    if (context.lib && *context.lib) {
        iov[i].iov_base = " ";
        iov[i++].iov_len = 1;
        iov[i].iov_base = (void *)context.lib;
        iov[i++].iov_len = strnlen(context.lib, 32);
    }
    if (context.file && *context.file) {
        iov[i].iov_base = " ";
        iov[i++].iov_len = 1;
        iov[i].iov_base = (void *)context.file;
        iov[i++].iov_len = strnlen(context.file, 32);
        iov[i].iov_base = ":";
        iov[i++].iov_len = 1;
        char lineBuffer[10];
        int lineLength = snprintf(lineBuffer, sizeof(lineBuffer), context.line < 1000 ? "%03u" : "%06u", context.line);
        iov[i].iov_base = lineBuffer;
        iov[i++].iov_len = sizeof(lineBuffer) - 1 < lineLength ? sizeof(lineBuffer) - 1 : lineLength;
    }
    if (context.tag && *context.tag) {
        iov[i].iov_base = "] [";
        iov[i++].iov_len = 3;
        iov[i].iov_base = (void *)context.tag;
        iov[i++].iov_len = strnlen(context.tag, 32);
    }

    iov[i].iov_base = "] ";
    iov[i++].iov_len = 2;

    CFRange range = CFRangeMake(0, message ? CFStringGetLength(message) : 0);
    if (range.length) {
        // add message
        unsigned char messageBuffer[256];
        CFIndex messageLength = 0;
        CFIndex length = 1;

        while (length && range.length) {
            length = CFStringGetBytes(message, range, kCFStringEncodingUTF8, '?', false, messageBuffer, sizeof(messageBuffer), &messageLength);
            iov[i].iov_base = messageBuffer;
            iov[i++].iov_len = messageLength;
            if (length >= range.length) {
                iov[i].iov_base = "\n";
                iov[i++].iov_len = 1;
            } else if (!length) {
                iov[i].iov_base = "~\n";
                iov[i++].iov_len = 2;
            }
            writev(STDERR_FILENO, iov, i);
            i = 0;
            range.location += length;
            range.length -= length;
        }
    } else {
        iov[i].iov_base = "\n";
        iov[i++].iov_len = 1;
        writev(STDERR_FILENO, iov, i);
    }
}


#pragma mark - Filtering

NWSLAction NWSLMatchingActionForContext(NWSLContext context) {
    NWSLAction result = kNWSLAction_none;
    int bestScore = 0;
    for (int i = 0; i < NWSLFilters.count; i++) {
        NWSLFilter *filter = &NWSLFilters.elements[i];
        if (result < filter->action) {
            int score = 0;
            const char *s = NULL;
#define _NWSL_FIND_(_prop) s = filter->properties[kNWSLProperty_##_prop]; if (s && context._prop) {if (strcasecmp(s, context._prop)) {continue;} else {score++;}}
            _NWSL_FIND_(tag)
            _NWSL_FIND_(lib)
            _NWSL_FIND_(file)
            _NWSL_FIND_(function)
            if (bestScore <= score) {
                bestScore = score;
                result = filter->action;
            }
        }
    }
    return result;
}

static int NWSLAddFilter1(NWSLFilter *filter) {
    if (filter->action != kNWSLAction_none) {
        int count = NWSLFilters.count;
        if (count < kNWSLFilterListSize) {
            NWSLFilters.elements[count] = *filter;
            NWSLFilters.count = count + 1;
            return true;
        }
    }
    return false;
}

static NWSLAction NWSLHasFilter1(NWSLFilter *filter) {
    for (int i = 0; i < NWSLFilters.count; i++) {
        NWSLFilter *m = &NWSLFilters.elements[i];
        int j = 1;
        for (; j < kNWSLProperty_count; j++) {
            const char *a = filter->properties[j];
            const char *b = m->properties[j];
            if (a != b && (!a || !b || strcasecmp(a, b))) break;
        }
        if (j == kNWSLProperty_count) {
            return m->action;
        }
    }
    return kNWSLAction_none;
}

static int NWSLRemoveFilter1(NWSLFilter *filter) {
    int result = 0;
    for (int i = 0; i < NWSLFilters.count; i++) {
        NWSLFilter *m = &NWSLFilters.elements[i];
        int j = 1;
        for (; j < kNWSLProperty_count; j++) {
            const char *a = filter->properties[j];
            const char *b = m->properties[j];
            if (a != b && (!a || !b || strcasecmp(a, b))) break;
        }
        int count = NWSLFilters.count;
        if (j == kNWSLProperty_count && count > 0) {
            NWSLFilters.count = count - 1;
            NWSLFilters.elements[i--] = NWSLFilters.elements[count - 1];
            result++;
        }
    }
    return result;
}

static int NWSLRemoveMatchingFilters1(NWSLFilter *filter) {
    int result = 0;
    for (int i = 0; i < NWSLFilters.count; i++) {
        NWSLFilter *m = &NWSLFilters.elements[i];
        int j = 1;
        for (; j < kNWSLProperty_count; j++) {
            const char *a = filter->properties[j];
            const char *b = m->properties[j];
            if (a && (!b || strcasecmp(a, b))) break;
        }
        int count = NWSLFilters.count;
        if (j == kNWSLProperty_count && count > 0) {
            NWSLFilters.count = count - 1;
            NWSLFilters.elements[i--] = NWSLFilters.elements[count - 1];
            result++;
        }
    }
    return result;
}

int NWSLAddFilter(const char *tag, const char *lib, const char *file, const char *function, NWSLAction action) {
    NWSLFilter filter = {NULL, tag, lib, file, function, action};
    NWSLRemoveFilter1(&filter);
    int result = NWSLAddFilter1(&filter);
    return result;
}

NWSLAction NWSLHasFilter(const char *tag, const char *lib, const char *file, const char *function) {
    NWSLFilter filter = {NULL, tag, lib, file, function, kNWSLAction_none};
    NWSLAction result = NWSLHasFilter1(&filter);
    return result;
}

int NWSLRemoveMatchingFilters(const char *tag, const char *lib, const char *file, const char *function) {
    NWSLFilter filter = {NULL, tag, lib, file, function, kNWSLAction_none};
    int result = NWSLRemoveMatchingFilters1(&filter);
    return result;
}

void NWSLRemoveAllFilters(void) {
    NWSLFilters.count = 0;
}

void NWSLAddDefaultFilter(void) {
    NWSLAddFilter(NWSLDefaultFilterTag, NULL, NULL, NULL, NWSLDefaultFilterAction);
}

void NWSLRestoreDefaultFilters(void) {
    NWSLRemoveAllFilters();
    NWSLAddDefaultFilter();
}


#pragma mark - Clock

double NWSLTime(void) {
    return CFAbsoluteTimeGetCurrent() + 978307200;
}

void NWSLResetPrintClock(void) {
    NWSLTimeOffset = NWSLTime();
}

void NWSLOffsetPrintClock(double seconds) {
    NWSLTimeOffset = -seconds;
}

void NWSLRestorePrintClock(void) {
    NWSLTimeOffset = 0;
}

void NWSLClock(double time, int *hour, int *minute, int *second, int *micro) {
    double t = time - NWSLTimeOffset;
    *hour = (int)(t / 3600) % 24;
    *minute = (int)(t / 60) % 60;
    *second = (int)t % 60;
    *micro = (int)((t - floor(t)) * 1000000) % 1000000;
}


#pragma mark - About

#define _NWSL_PRINT_(_buffer, _size, _fmt, ...) do {\
        int _s = _size > 0 ? _size : 0;\
        int __p = snprintf(_buffer, _s, _fmt, ##__VA_ARGS__);\
        if (__p <= _size) _buffer += __p; else buffer += _s;\
        _size -= __p;\
    } while (0)

int NWSLAboutString(char *buffer, int size) {
    int s = size;
    for (int i = 0; i < NWSLFilters.count; i++) {
        NWSLFilter *filter = &NWSLFilters.elements[i];
#define _NWSL_ABOUT_ACTION_(_action) do {if (filter->action == kNWSLAction_##_action) {_NWSL_PRINT_(buffer, s, "   action       : "#_action);}} while (0)
        _NWSL_ABOUT_ACTION_(print);
        _NWSL_ABOUT_ACTION_(break);
        const char *value = NULL;
#define _NWSL_ABOUT_PROP_(_prop) do {if ((value = filter->properties[kNWSLProperty_##_prop])) {_NWSL_PRINT_(buffer, s, " "#_prop"=%s", value);}} while (0)
        _NWSL_ABOUT_PROP_(tag);
        _NWSL_ABOUT_PROP_(lib);
        _NWSL_ABOUT_PROP_(file);
        _NWSL_ABOUT_PROP_(function);
        _NWSL_PRINT_(buffer, s, "\n");
    }
    for (int i = 0; i < NWSLPrinters.count; i++) {
        NWSLPrinter *p = &NWSLPrinters.elements[i];
        _NWSL_PRINT_(buffer, s, "   printer      : %s\n", p->name);
    }
    _NWSL_PRINT_(buffer, s, "   time-offset  : %f\n", NWSLTimeOffset);
    return size - s;
}

void NWSLogAbout(void) {
    char buffer[256];
    int length = NWSLAboutString(buffer, sizeof(buffer));
    NWSLContext context = {NULL, "NWSLogging", NULL, 0, NULL, NWSLTime()};
    CFStringRef message = CFStringCreateWithFormat(NULL, 0, CFSTR("About NWSLogging\n%s%s"), buffer, length <= sizeof(buffer) - 1 ? "" : "\n   ...");\
    NWSLForwardToPrinters(context, message);
    CFRelease(message);
}


#pragma mark - Misc Helpers

void NWSLRestore(void) {
    NWSLRestoreDefaultFilters();
    NWSLRestoreDefaultPrinters();
    NWSLRestorePrintClock();
}


#pragma mark - Macro wrappers

void NWSLPrintInfo(void) {
    NWSLAddFilter("info", NULL, NULL, NULL, kNWSLAction_print);
}

void NWSLPrintWarn(void) {
    NWSLAddFilter("warn", NULL, NULL, NULL, kNWSLAction_print);
}

void NWSLPrintDbug(void) {
    NWSLAddFilter("dbug", NULL, NULL, NULL, kNWSLAction_print);
}

void NWSLPrintTag(const char *tag) {
    NWSLAddFilter(tag, NULL, NULL, NULL, kNWSLAction_print);
}

void NWSLPrintAll(void) {
    NWSLAddFilter(NULL, NULL, NULL, NULL, kNWSLAction_print);
}



void NWSLPrintInfoInLib(const char *lib) {
    NWSLAddFilter("info", lib, NULL, NULL, kNWSLAction_print);
}

void NWSLPrintWarnInLib(const char *lib) {
    NWSLAddFilter("warn", lib, NULL, NULL, kNWSLAction_print);
}

void NWSLPrintDbugInLib(const char *lib) {
    NWSLAddFilter("dbug", lib, NULL, NULL, kNWSLAction_print);
}

void NWSLPrintTagInLib(const char *tag, const char *lib) {
    NWSLAddFilter(tag, lib, NULL, NULL, kNWSLAction_print);
}

void NWSLPrintAllInLib(const char *lib) {
    NWSLAddFilter(NULL, lib, NULL, NULL, kNWSLAction_print);
}



void NWSLPrintDbugInFile(const char *file) {
    NWSLAddFilter("dbug", NULL, file, NULL, kNWSLAction_print);
}

void NWSLPrintAllInFile(const char *file) {
    NWSLAddFilter(NULL, NULL, file, NULL, kNWSLAction_print);
}

void NWSLPrintDbugInFunction(const char *function) {
    NWSLAddFilter("dbug", NULL, NULL, function, kNWSLAction_print);
}



void NWSLBreakWarn(void) {
    NWSLAddFilter("warn", NULL, NULL, NULL, kNWSLAction_break);
}

void NWSLBreakWarnInLib(const char *lib) {
    NWSLAddFilter("warn", lib, NULL, NULL, kNWSLAction_break);
}

void NWSLBreakTag(const char *tag) {
    NWSLAddFilter(tag, NULL, NULL, NULL, kNWSLAction_break);
}

void NWSLBreakTagInLib(const char *tag, const char *lib) {
    NWSLAddFilter(tag, lib, NULL, NULL, kNWSLAction_break);
}



void NWSLClearInfo(void) {
    NWSLRemoveMatchingFilters("info", NULL, NULL, NULL);
}

void NWSLClearWarn(void) {
    NWSLRemoveMatchingFilters("warn", NULL, NULL, NULL);
}

void NWSLClearDbug(void) {
    NWSLRemoveMatchingFilters("dbug", NULL, NULL, NULL);
}

void NWSLClearTag(const char *tag) {
    NWSLRemoveMatchingFilters(tag, NULL, NULL, NULL);
}

void NWSLClearAllInLib(const char *lib) {
    NWSLRemoveMatchingFilters(NULL, lib, NULL, NULL);
}

void NWSLClearAll(void) {
    NWSLRemoveAllFilters();
}


#pragma mark - Debugging

void NWSLBreakInDebugger(void) {
    struct kinfo_proc info;
    info.kp_proc.p_flag = 0;
    pid_t pid = getpid();
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, pid};
    size_t size = sizeof(info);
    sysctl(mib, 4, &info, &size, NULL, 0);
    if (info.kp_proc.p_flag & P_TRACED) {
        kill(pid, SIGINT);
    }
}

void NWSLDumpConfig(void) {
    char buffer[256];
    int length = NWSLAboutString(buffer, sizeof(buffer));
    struct iovec iov[2];
    iov[0].iov_base = buffer;
    iov[0].iov_len = length <= sizeof(buffer) - 1 ? length : sizeof(buffer) - 1;
    iov[1].iov_base = "   ...\n";
    iov[1].iov_len = length <= sizeof(buffer) - 1 ? 0 : 7;
    writev(STDERR_FILENO, iov, 2);
}

#define PRINT(_format, ...) fprintf(stderr, _format"\n", ##__VA_ARGS__)
void NWSLDumpFlags(int active, const char *lib, int debug, const char *file, int line, const char *function) {
    PRINT("   file         : %s:%i", file, line);
    PRINT("   function     : %s", function);
    PRINT("   DEBUG        : %s", debug ? "YES" : "NO");
    PRINT("   NWSL_LIB      : %s", lib && *lib ? lib : (lib ? "<empty>" : "<not set>"));
    PRINT("   NWSLog macros : %s", active ? "YES" : "NO");
}

#undef NWSLDump
void NWSLDump(void) {
    NWSLDumpConfig();
}
