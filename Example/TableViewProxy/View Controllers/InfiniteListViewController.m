//
//  InfiniteListViewControllerT.m
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "InfiniteListViewController.h"

#import "LoadingCell.h"
#import "DemoCell.h"

#import <PVGTableViewProxy.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface InfiniteListViewController ()

@property (readwrite, nonatomic) PVGTableViewProxy *proxy;

@end

@implementation InfiniteListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
}

- (void)setupTableView
{
    PVGTableViewSimpleDataSource *dataSource = [PVGTableViewSimpleDataSource dataSourceWithViewModels:RACObserve(self.viewModel, items)];
    dataSource.delegate = self;
    
    self.proxy = [PVGTableViewProxy proxyWithTableView:self.tableView
                                               builder:^(id<PVGTableViewProxyConfig> builder) {
                                                   PVGTableViewSection *section = [PVGTableViewSection sectionWithDataSource:dataSource];
                                                   [builder addSection:section atIndex:0];
                                                   
                                                   UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([DemoCell class]) bundle:nil];
                                                   [builder registerNib:cellNib
                                                 forCellReuseIdentifier:DEMO_CELL_REUSE_IDENTIFIER];
                                                   
                                                   UINib *loadinCellNib = [UINib nibWithNibName:NSStringFromClass([LoadingCell class]) bundle:nil];
                                                   [builder registerNib:loadinCellNib forCellReuseIdentifier:LOADING_CELL_REUSE_IDENTIFIER];
                                               }];
}

- (IBAction)toggle:(id)sender
{
    self.viewModel.shouldLoadSync = !self.viewModel.shouldLoadSync;
}

- (void)loadMoreDataWithCurrentData:(NSArray *)currentData
{
    [self.viewModel loadMoreData];
}

@end
