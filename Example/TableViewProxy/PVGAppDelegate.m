//
//  PVGAppDelegate.m
//  PVGTableViewProxy
//
//  Created by Jóhann Þ. Bergþórsson on 09/20/2015.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "PVGAppDelegate.h"

#import "RootViewController.h"

@implementation PVGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    RootViewController *viewController = (RootViewController*)[storyboard instantiateViewControllerWithIdentifier: @"root"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
