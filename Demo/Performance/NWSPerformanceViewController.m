//
//  NWSPerformanceViewController.m
//  NWService
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSPerformanceViewController.h"
#import "NWService.h"
#import "JSONKit.h"
#import "NWSVarStat.h"
#import "NWSCommon.h"
#import "NWSMapsService.h"


#define Log(__a, ...) [self printLine:YES format:__a, ##__VA_ARGS__]
#define L(__a, ...) [self printLine:NO format:__a, ##__VA_ARGS__]

@implementation NWSPerformanceViewController {
    UITextView *textView;
    NWSBackend *backend;
    NWSStore *store;
    NSString *indent;
}


#pragma mark - Object life cycle

- (void)loadWithContext:(NSManagedObjectContext *)context;
{
    NSURL *modelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"Maps" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    
    NSURL *documentsURL = [[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"Maps.sqlite"];
    NSError *error = nil;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    NWLogWarnIfError(error);
    NWLogWarnIfNot(newStore, @"Unable to add persistent store with url: %@", storeURL);
    
    NSManagedObjectContext *result = [[NSManagedObjectContext alloc] init];
    [result setPersistentStoreCoordinator:coordinator];
    
    backend = NWSMapsService.backend;
    store = [[NWSCoreDataStore alloc] initWithContext:context queue:NSOperationQueue.mainQueue];
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        [self loadWithContext:context];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    indent = @"   ";
    Log(@"");
    Log(@"== NWService performance test ==");
    [self.view addSubview:textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self start];
}

#pragma mark - Logging

- (void)printLine:(BOOL)line format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *l = [[NSString alloc] initWithFormat:format arguments:args];
    if (line) {
        l = [l stringByAppendingFormat:@"\n%@", indent];
    }
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        textView.text = [textView.text stringByAppendingString:l];
    }];
    va_end(args);
}


#pragma mark - Performance testing

- (void)start
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [queue addOperationWithBlock:^{[NSThread sleepForTimeInterval:1];}];
    [queue addOperationWithBlock:^{[self testChannel];}];
    [queue addOperationWithBlock:^{[NSThread sleepForTimeInterval:1];}];
    [queue addOperationWithBlock:^{[self testChannels];}];
    [queue addOperationWithBlock:^{[NSThread sleepForTimeInterval:1];}];
}

- (void)testChannel
{
    static NSUInteger count = 200;
    
    Log(@"");
    Log(@"Mapping channel %u times:", count);
    
    NSDictionary *json = [[NSString stringWithContentsOfURL:[[NSBundle bundleForClass:self.class] URLForResource:@"channel" withExtension:@"json"] encoding:NSUTF8StringEncoding error:nil] objectFromJSONString];
    
    NWSStore *s = [store beginTransaction];
    
    NWSVarStat *stat = [[NWSVarStat alloc] init];
    for (NSUInteger i = 0; i < count; i++) {
        NSDate *d = NSDate.date;
        [[backend mappingWithName:@"channel"] mapElement:json store:s];
        [stat count:-[d timeIntervalSinceNow]];
        L(@".");
    }
    Log(@"");
    Log(@"Seconds per mapping: %@", stat.readable);
}

- (void)testChannels
{    
    static NSUInteger count = 20;

    NSArray *json = [[[NSString stringWithContentsOfURL:[[NSBundle bundleForClass:self.class] URLForResource:@"channels" withExtension:@"json"] encoding:NSUTF8StringEncoding error:nil] objectFromJSONString] objectForKey:@"results"];
    
    Log(@"");
    Log(@"Mapping %u channels %u times:", json.count, count);
    
    NWSStore *s = [store beginTransaction];
    
    NWSVarStat *stat = [[NWSVarStat alloc] init];
    for (NSUInteger i = 0; i < count; i++) {
        NSDate *d = NSDate.date;
        [[backend mappingWithName:@"channel"] mapElement:json store:s];
        [stat count:-[d timeIntervalSinceNow]];
        L(@".");
    }
    Log(@"");
    Log(@"Seconds per mapping: %@", stat.readable);
    Log(@"Seconds per channel: %f", stat.average / json.count);
}

@end
