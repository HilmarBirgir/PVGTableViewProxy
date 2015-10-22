//
//  ExampleScene.m
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "StaticListViewController.h"

#import <PVGTableViewProxy.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DemoCell.h"

@interface StaticListViewController ()

@property (readwrite, nonatomic) PVGTableViewProxy *proxy;

@end

@implementation StaticListViewController

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
                                                   UINib *nib = [UINib nibWithNibName:NSStringFromClass([DemoCell class]) bundle:nil];
                                                   [builder registerNib:nib
                                                 forCellReuseIdentifier:DEMO_CELL_REUSE_IDENTIFIER];
                                               }];
}

@end
