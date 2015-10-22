//
//  ManualUpdateListViewController.h
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ForceUpdateListViewModel.h"

@interface ForceUpdateListViewController : UITableViewController

@property (readwrite, nonatomic) ForceUpdateListViewModel *viewModel;

@end
