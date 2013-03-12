//
//  NWSMenuViewController.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSMenuViewController.h"
#import "NWSPerformanceViewController.h"
#import "NWSBasicExampleTableViewController.h"

@implementation NWSMenuViewController {
    NSManagedObjectContext *_context;
}


#pragma mark - Object life cycle

- (void)viewWillAppear:(BOOL)animated
{
    // fast forward:
//    [self selectController:1 animated:NO];
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
        case 0: cell.textLabel.text = @"Performance"; break;
        case 1: cell.textLabel.text = @"BasicExample"; break;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)selectController:(NSInteger)index animated:(BOOL)animated
{
    UIViewController* controller = nil;
    switch (index) {
        case 0: controller = [[NWSPerformanceViewController alloc] initWithContext:_context]; break;
        case 1: controller = [[NWSBasicExampleTableViewController alloc] initWithStyle:UITableViewStylePlain]; break;
    }
    
    [self.navigationController pushViewController:controller animated:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectController:indexPath.row animated:YES];
}

@end
