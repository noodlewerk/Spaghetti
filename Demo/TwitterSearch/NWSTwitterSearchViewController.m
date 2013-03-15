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
- (id)initWithMessage:(TwitterMessage *)message;
@end


@interface NWSTwitterSearchViewController() <NSFetchedResultsControllerDelegate, UITableViewDataSource, UISearchBarDelegate>
@end


#pragma mark -

@implementation NWSTwitterSearchViewController {
    NSManagedObjectModel *_model;
    NSManagedObjectContext *_context;
    NSFetchedResultsController *_fetchedResultsController;
    NWSHTTPEndpoint *_endpoint;
    NSString *_searchQueue;
    BOOL _searchingBackend;
    UIActivityIndicatorView *_spinner;
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
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    _model = model;
    _context = context;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TwitterMessage"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    _fetchedResultsController = controller;
}

- (void)setupEndpoint
{
    NWSTransform *dateTransform = [[NWSDateFormatterTransform alloc] initWithString:@"E, dd MMM yyyy HH:mm:ss Z"];
    
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
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(searchBar.bounds.size.width - 48, searchBar.bounds.size.height / 2);
    [searchBar addSubview:spinner];
    _spinner = spinner;
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
        [_spinner startAnimating];
        
        // send HTTP request to twitter web server
        [_endpoint startWithParameters:@{@"query":string} block:^(NSArray *messages) {
            
            // mark results with query string, so we can filter them in the table view
            for (TwitterMessage *message in messages) {
                message.search = string;
            }
            _searchingBackend = NO;
            [_spinner stopAnimating];
            
            if (_searchQueue.length) {
                // pop the next query from the queue
                [self searchBackendWithString:_searchQueue];
            } else {
                // redo search in 5 seconds
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
    [self searchWithString:[(UISearchBar *)self.tableView.tableHeaderView text]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelBackendSearch];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fetchedResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass(self.class)];
    TwitterMessage *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = message.text;
    cell.detailTextLabel.text = message.user.fullname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TwitterMessage *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    NWSTwitterDetailsViewController *controller = [[NWSTwitterDetailsViewController alloc] initWithMessage:message];
    [self.navigationController pushViewController:controller animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = [object text];
        } break;
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
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


#pragma mark -

@implementation NWSTwitterDetailsViewController {
    NSMutableArray *_pairs;
}

- (id)initWithMessage:(TwitterMessage *)message
{
    self = [super init];
    if (self) {
        _pairs = @[].mutableCopy;
        if (message.text.length) [_pairs addObject:@[@"Message", message.text]];
        if (message.user.fullname.length) [_pairs addObject:@[@"By", message.user.fullname]];
        if (message.date) [_pairs addObject:@[@"On", [message.date descriptionWithLocale:NSLocale.currentLocale]]];
        if (message.location) [_pairs addObject:@[@"At", message.location]];
        if (message.language) [_pairs addObject:@[@"Language", message.language]];
        if (message.image) [_pairs addObject:@[@"Image URL", message.image]];
        if (message.source) [_pairs addObject:@[@"Source", message.source]];
        if (message.type) [_pairs addObject:@[@"Type", message.type]];
    }
    return self;
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
