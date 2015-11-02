//
//  SectionsViewController.h
//  PVGTableViewProxyExample
//
//  Created by Alexander Annas Helgason on 24/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SectionsListViewModel.h"

@interface SectionsListViewController : UITableViewController

@property (readwrite, nonatomic) SectionsListViewModel *viewModel;

@end
