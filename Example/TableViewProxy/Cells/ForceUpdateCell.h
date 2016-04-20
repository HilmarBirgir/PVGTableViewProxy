//
//  ForceUpdateCell.h
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PVGTableViewProxy/PVGTableViewCell.h>

#import "ForceUpdateCellViewModel.h"

@interface ForceUpdateCell : UITableViewCell<PVGTableViewCell>

@property (readwrite, nonatomic) ForceUpdateCellViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@end
