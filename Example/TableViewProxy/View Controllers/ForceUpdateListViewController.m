//
//  ManualUpdateListViewController.m
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "ForceUpdateListViewController.h"

#import "ForceUpdateCell.h"

#import <PVGTableViewProxy/PVGTableViewProxy.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ForceUpdateListViewController ()

@property (readwrite, nonatomic) PVGTableViewProxy *proxy;

@end

@implementation ForceUpdateListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
}

- (void)setupTableView
{
    self.proxy = [PVGTableViewProxy proxyWithTableView:self.tableView
                                            dataSource:RACObserve(self.viewModel, items)
                                               builder:^(id<PVGTableViewProxyConfig> builder) {
                                                   UINib *nib = [UINib nibWithNibName:NSStringFromClass([ForceUpdateCell class]) bundle:nil];
                                                   [builder registerNib:nib
                                                 forCellReuseIdentifier:FORCE_UPDATE_CELL_REUSE_IDENTIFIER];
                                               }];
}

@end
