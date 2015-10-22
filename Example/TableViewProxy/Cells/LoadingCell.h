//
//  LoadingCell.h
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <PVGTableViewCell.h>

#import "LoadingCellViewModel.h"

@interface LoadingCell : UITableViewCell<PVGTableViewCell>

@property (readwrite, nonatomic) LoadingCellViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
