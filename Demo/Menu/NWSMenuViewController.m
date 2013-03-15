//
//  NWSMenuViewController.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMenuViewController.h"
#import "NWSGoogleMapsViewController.h"
#import "NWSTwitterSearchViewController.h"


@implementation NWSMenuViewController


#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Menu";
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self selectController:1 animated:NO]; // fast forward
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    switch (indexPath.row) {
        case 0: cell.textLabel.text = @"Google Maps"; break;
        case 1: cell.textLabel.text = @"Twitter Search"; break;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)selectController:(NSInteger)index animated:(BOOL)animated
{
    UIViewController* controller = nil;
    switch (index) {
        case 0: controller = [[NWSGoogleMapsViewController alloc] init]; break;
        case 1: controller = [[NWSTwitterSearchViewController alloc] init]; break;
    }
    
    [self.navigationController pushViewController:controller animated:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectController:indexPath.row animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
