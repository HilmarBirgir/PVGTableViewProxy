//
//  InfiniteListViewControllerT.h
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InfiniteListViewModel.h"
#import <PVGTableViewProxy/PVGTableViewSimpleDataSource.h>

@interface InfiniteListViewController : UIViewController<PVGTableViewSimpleDataSourceLoadMoreDelegate>

@property (readwrite, nonatomic) InfiniteListViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
