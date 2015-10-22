//
//  DemoCell.h
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <PVGTableViewCell.h>

#import "DemoCellViewModel.h"

@interface DemoCell : UITableViewCell<PVGTableViewCell>

@property (readwrite, nonatomic) DemoCellViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@end
