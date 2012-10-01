//
//  NWLPrinter.h
//  NWLogging
//
//  Created by leonard on 6/7/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

@protocol NWLPrinter <NSObject>

@required
- (void)printWithTag:(NSString *)tag lib:(NSString *)lib file:(NSString *)file line:(NSUInteger)line function:(NSString *)function message:(NSString *)message;

@optional
- (NSString *)printerName;

@end
