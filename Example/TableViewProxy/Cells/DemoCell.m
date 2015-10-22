//
//  DemoCell.m
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "DemoCell.h"

@interface DemoCell ()

@end

@implementation DemoCell

#pragma mark - PVGTableViewCell

- (NSNumber *)height
{
    return @50;
}

- (void)setup
{
    self.userIDLabel.text = self.viewModel.ID;
    self.contentView.backgroundColor = self.viewModel.color;
}

@end
