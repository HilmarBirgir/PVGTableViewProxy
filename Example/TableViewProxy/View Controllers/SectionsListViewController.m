//
//  SectionsViewController.m
//  PVGTableViewProxyExample
//
//  Created by Alexander Annas Helgason on 24/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "SectionsListViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <PVGTableViewProxy/PVGTableViewProxy.h>
#import "DemoCell.h"

@interface SectionsListViewController ()

@property (readwrite, nonatomic) PVGTableViewProxy *proxy;

@end

@implementation SectionsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
}

- (void)setupTableView
{
    PVGTableViewSimpleDataSource *yellowDataSource = [PVGTableViewSimpleDataSource dataSourceWithViewModels:RACObserve(self.viewModel, yellowItems)];
    PVGTableViewSection *yellowSection = [PVGTableViewSection sectionWithDataSource:yellowDataSource];
    
    PVGTableViewSimpleDataSource *greenDataSource = [PVGTableViewSimpleDataSource dataSourceWithViewModels:RACObserve(self.viewModel, greenItems)];
    PVGTableViewSection *greenSection = [PVGTableViewSection sectionWithDataSource:greenDataSource];
    
    TableViewProxyBuilderBlock builderBlock = ^(id<PVGTableViewProxyConfig> builder) {
        [builder addSection:yellowSection atIndex:0];
        [builder addSection:greenSection atIndex:1];
        
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([DemoCell class]) bundle:nil];
        [builder registerNib:nib forCellReuseIdentifier:DEMO_CELL_REUSE_IDENTIFIER];
    };
    
    self.proxy = [PVGTableViewProxy proxyWithTableView:self.tableView builder:builderBlock];
}

@end
