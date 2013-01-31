//
//  NWSAppDelegate.m
//  Spaghetti
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWSAppDelegate.h"
#import "NWSMenuViewController.h"


@implementation NWSAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen.mainScreen bounds]];
    
    NWSMenuViewController *controller = [[NWSMenuViewController alloc] init];

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = UIColor.whiteColor;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
