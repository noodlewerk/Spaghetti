//
//  NWSBasicExampleTableViewController.m
//  Spaghetti
//
//  Created by Bruno Scheele on 5/28/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSBasicExampleTableViewController.h"
#import "Spaghetti.h"

#pragma mark -

@implementation NWSBasicExampleTwitterMessage
@synthesize sender;
@synthesize text;
@synthesize date;
@end

#pragma mark -

@implementation NWSBasicExampleBackend 

#pragma mark Lifecycle

+ (NWSBasicExampleBackend *)shared {
    static NWSBasicExampleBackend *backend = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        backend = [[NWSBasicExampleBackend alloc] init];
    });
    return backend;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Create a mapping. 
        // Multiple mappings are more easily created with copy/paste when enclosed in acolades.
        {
            // The name of the mapping should be descriptive.
            // Also, since we are creating the mapping, make sure to specify an NWSMapping class or subclass.
            NWSMapping *mapping = [self mappingWithName:@"twitterMessage" createWithClass:[NWSMapping class]];
            
            // The mapping has to know to which class type the response maps.
            [mapping setObjectClassName:@"NWSBasicExampleTwitterMessage"];
            
            // Example of mapping an attribute to a property with the same name.
            [mapping addAttributeWithPath:@"text"];
            
            // Example of mapping an attribute to a property with a different name.
            [mapping addAttributeWithElementPath:@"from_user" objectPath:@"sender"];
            
            // Example of mapping an attribute to a property with a transform.
            NWSTransform *dateTransform = [[NWSDateFormatterTransform alloc] initWithString:@"E, d MMM yyyy HH:mm:ss Z" localeString:@"en_US"];
            [mapping addAttributeWithElementPath:@"created_at" objectPath:@"date" transform:dateTransform];
        }
        
        // Create an HTTP endpoint.
        // Multiple endpoints are more easily created with copy/paste when enclosed in acolades.
        {
            // The name of the endpoint should be descriptive.
            // The same as with the mapping, make sure to specify an NWSEndpoint class or subclass.
            NWSHTTPEndpoint *endpoint = [self endpointWithName:@"3fmTwitterStream" createWithClass:[NWSHTTPEndpoint class]];
            
            // Specify the URL for the endpoint. We're leaving parameters for another example.
            endpoint.urlString = @"http://search.twitter.com/search.json?q=3fm&count=5&result_type=mixed";
            
            // Specify the mapping this endpoint will use.
            endpoint.responseMapping = [self mappingWithName:@"twitterMessage"];
            
            // Because often the returned result contains lists of the desired object, specify in which array the object will be with an NWSPath.
            endpoint.responsePath = [NWSPath pathFromString:@"results"];
        }
    }
    return self;
}

@end

#pragma mark -

@implementation NWSBasicExampleTableViewController {
    NWSBasicExampleBackend *backend;
    NSArray *tweets;
}

#pragma mark Lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        backend = [NWSBasicExampleBackend shared];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the call for getting the Twitter message.
    NWSCall *twitterCall = [[NWSBasicExampleBackend shared] callWithEndpoint:@"3fmTwitterStream"];
    
    // Add a done block to process the returned data.
    twitterCall.doneBlock = ^(id results) {
        // First check if there's a result. If not, something has gone wrong.
        if (results) {
            tweets = (NSArray *)results;
            [self.tableView reloadData];
        }
        else {
            // Something went wrong. The top layers of Spaghetti already got all of the heavy errors, so this part is better off handling any user interaction.
        }
    };
    
    // Actually schedule the call.
    [[NWSBasicExampleBackend shared] scheduleCall:twitterCall owner:nil];
    
    /// @todo Somehow make a convenience method for adding doneblocks?
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"tweetCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NWSBasicExampleTwitterMessage *tweet = [tweets objectAtIndex:indexPath.row];
    NSString *senderAndMessageString = [NSString stringWithFormat:@"@%@: %@", tweet.sender, tweet.text];
    int maximumCharacters = 40;
    if ([senderAndMessageString length] > maximumCharacters) {
        senderAndMessageString = [senderAndMessageString stringByReplacingCharactersInRange:NSMakeRange(maximumCharacters, [senderAndMessageString length] - maximumCharacters) withString:@"…"];
    }
    cell.textLabel.text = senderAndMessageString;
    cell.detailTextLabel.text = [tweet.date description];
    
    return cell;
}

@end



