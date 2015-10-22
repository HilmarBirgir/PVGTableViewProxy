//
//  ForceUpdateCell.m
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "ForceUpdateCell.h"

@implementation ForceUpdateCell

#pragma mark - PVGTableViewCell

- (NSNumber *)height
{
    return @50;
}

- (void)setup
{
    self.userIDLabel.text = self.viewModel.ID;
    self.contentView.backgroundColor = [self.viewModel randomColor];
}

@end
