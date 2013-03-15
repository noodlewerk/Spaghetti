//
//  NWSTwitterSearchViewController.m
//  Spaghetti
//
//  Copyright (c) 2013 noodlewerk. All rights reserved.
//

#import "NWSTwitterSearchViewController.h"
#import "Spaghetti.h"

@class TwitterMessage, TwitterUser;


@interface TwitterUser : NSManagedObject
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSSet *messages;
@end

@interface TwitterMessage : NSManagedObject
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) TwitterUser *user;
@property (nonatomic, strong) NSString *search;
@end


@interface NWSTwitterDetailsViewController : UITableViewController
@property (nonatomic, strong) TwitterMessage *message;
@end


@interface NWSTwitterSearchViewController() <NSFetchedResultsControllerDelegate, UITableViewDataSource, UISearchBarDelegate>
@end

@implementation NWSTwitterSearchViewController {
    NSManagedObjectModel *_model;
    NSManagedObjectContext *_context;
    NSFetchedResultsController *_fetchedResultsController;
    NWSHTTPEndpoint *_endpoint;
    NSString *_searchQueue;
    BOOL _searchingBackend;
}


#pragma mark - Object life cycle

- (id)init
{
    return [super initWithStyle:UITableViewStylePlain];
}

- (void)dealloc
{
    _fetchedResultsController.delegate = nil;
    [self cancelBackendSearch];
}


#pragma mark - Setup

- (void)setupContext
{
    NSURL *modelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"NWSTwitter" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setPersistentStoreCoordinator:coordinator];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TwitterMessage"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    NSError *error = nil;
    [controller performFetch:&error];
    NWError(error);

    _model = model;
    _context = context;
    _fetchedResultsController = controller;
}

- (void)setupEndpoint
{
    NWSTransform *dateTransform = [[NWSDateFormatterTransform alloc] initWithString:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    
    NWSMapping *userMapping = [[NWSMapping alloc] init];
    [userMapping setObjectEntityName:@"TwitterUser" model:_model];
    [userMapping addAttributeWithElementPath:@"from_user_id" objectPath:@"identifier" isPrimary:YES];
    [userMapping addAttributeWithElementPath:@"from_user" objectPath:@"username"];
    [userMapping addAttributeWithElementPath:@"from_user_name" objectPath:@"fullname"];
    
    NWSMapping *messageMapping = [[NWSMapping alloc] init];
    [messageMapping setObjectEntityName:@"TwitterMessage" model:_model];
    [messageMapping addAttributeWithElementPath:@"id" objectPath:@"identifier" isPrimary:YES];
    [messageMapping addAttributeWithElementPath:@"text" objectPath:@"text"];
    [messageMapping addAttributeWithElementPath:@"created_at" objectPath:@"date" transform:dateTransform];
    [messageMapping addAttributeWithElementPath:@"geo.coordinates.0" objectPath:@"latitude"];
    [messageMapping addAttributeWithElementPath:@"geo.coordinates.1" objectPath:@"longitude"];
    [messageMapping addAttributeWithElementPath:@"place.full_name" objectPath:@"location"];
    [messageMapping addAttributeWithElementPath:@"iso_language_code" objectPath:@"language"];
    [messageMapping addAttributeWithElementPath:@"profile_image_url" objectPath:@"image"];
    [messageMapping addAttributeWithElementPath:@"metadata.result_type" objectPath:@"type"];
    [messageMapping addAttributeWithPath:@"source"];
    [messageMapping addRelationWithElementPath:@"" objectPath:@"user" mapping:userMapping policy:NWSPolicy.replaceOne];

    [NWSMappingValidator validate:userMapping];
    [NWSMappingValidator validate:messageMapping];
    
    NWSHTTPEndpoint *searchEndpoint = [[NWSHTTPEndpoint alloc] init];
    searchEndpoint.urlString = @"http://search.twitter.com/search.json?q=%(query)";
    searchEndpoint.responseMapping = messageMapping;
    searchEndpoint.responsePath = [NWSPath pathFromString:@"results"];
    searchEndpoint.store = [[NWSCoreDataStore alloc] initWithContext:_context queue:NSOperationQueue.mainQueue];
    _endpoint = searchEndpoint;
}

- (void)setupView
{
    self.title = @"Search Twitter";
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44)];
    searchBar.placeholder = @"Search Twitter";
    searchBar.text = @"Spaghetti";
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
}


#pragma mark - Search Core Data and Backend

- (void)searchWithString:(NSString *)string
{
    // update fetched results controller
    _fetchedResultsController.fetchRequest.predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"search"] rightExpression:[NSExpression expressionForConstantValue:string] modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
    NSError *error = nil;
    [_fetchedResultsController performFetch:&error];
    NWError(error);
    [self.tableView reloadData];
    
    [self searchBackendWithString:string];
}

- (void)searchBackendWithString:(NSString *)string
{
    [self cancelBackendSearch];
    if (_searchingBackend) {
        // a search is already in progress, so we queue this one
        _searchQueue = string;
        
    } else if (string.length) {
        _searchingBackend = YES;
        
        // send HTTP request to twitter web server
        [_endpoint startWithParameters:@{@"query":string} block:^(NSArray *messages) {
            
            // mark results with query string, so we can filter them in the table view
            for (TwitterMessage *message in messages) {
                message.search = string;
            }
            _searchingBackend = NO;
            
            // pop the next query from the queue
            if (_searchQueue.length) {
                [self searchBackendWithString:_searchQueue];
            } else {
                [self performSelector:@selector(searchBackendWithString:) withObject:string afterDelay:5];
            }
        }];
    }
}

- (void)cancelBackendSearch
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _searchQueue = nil;
}


#pragma mark - UITableViewController subclass

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupContext];
    [self setupEndpoint];
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self searchBackendWithString:[(UISearchBar *)self.tableView.tableHeaderView text]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelBackendSearch];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TwitterSearch";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    TwitterMessage *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = message.text;
    cell.detailTextLabel.text = message.user.fullname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NWSTwitterDetailsViewController *controller = [[NWSTwitterDetailsViewController alloc] init];
    controller.message = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:controller animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        } break;
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        } break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = [object text];
        } break;
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchWithString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end


@implementation NWSTwitterDetailsViewController {
    NSMutableArray *_pairs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pairs = @[].mutableCopy;
    if (_message.text.length) [_pairs addObject:@[@"Message", _message.text]];
    if (_message.user.fullname.length) [_pairs addObject:@[@"By", _message.user.fullname]];
    if (_message.date) [_pairs addObject:@[@"On", [_message.date descriptionWithLocale:NSLocale.currentLocale]]];
    if (_message.location) [_pairs addObject:@[@"At", _message.location]];
    if (_message.language) [_pairs addObject:@[@"Language", _message.language]];
    if (_message.image) [_pairs addObject:@[@"Image URL", _message.image]];
    if (_message.source) [_pairs addObject:@[@"Source", _message.source]];
    if (_message.type) [_pairs addObject:@[@"Type", _message.type]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pairs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TwitterSearch";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    NSArray *pair = _pairs[indexPath.row];
    cell.textLabel.text = pair[0];
    cell.detailTextLabel.text = pair[1];
    return cell;
}

@end
