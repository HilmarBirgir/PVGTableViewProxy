//
//  ExampleScene.h
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StaticListViewModel.h"

@interface StaticListViewController : UITableViewController

@property (readwrite, nonatomic) StaticListViewModel *viewModel;


@end
