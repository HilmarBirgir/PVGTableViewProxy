//
//  RootViewController.m
//  PVGTableViewProxy
//
//  Created by Hilmar Birgir Ólafsson on 12/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "RootViewController.h"
#import "StaticListViewController.h"
#import "InfiniteListViewController.h"
#import "ForceUpdateListViewController.h"
#import "SectionsListViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        StaticListViewModel *viewModel = [[StaticListViewModel alloc] init];
        StaticListViewController *viewController = [[StaticListViewController alloc] init];
        viewController.viewModel = viewModel;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (indexPath.row == 1)
    {
        InfiniteListViewModel *viewModel = [[InfiniteListViewModel alloc] init];
        InfiniteListViewController *viewController = [[InfiniteListViewController alloc] init];
        viewController.viewModel = viewModel;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (indexPath.row == 2)
    {
        ForceUpdateListViewModel *viewModel = [[ForceUpdateListViewModel alloc] init];
        ForceUpdateListViewController *viewController = [[ForceUpdateListViewController alloc] init];
        viewController.viewModel = viewModel;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (indexPath.row == 3)
    {
        SectionsListViewModel *viewModel = [SectionsListViewModel new];
        SectionsListViewController *viewController = [SectionsListViewController new];
        viewController.viewModel = viewModel;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
