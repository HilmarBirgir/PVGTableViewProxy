//
//  LoadingCell.m
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "LoadingCell.h"

@interface LoadingCell ()

@end

@implementation LoadingCell

#pragma mark - PVGTableViewCell

- (NSNumber *)height
{
    return @40;
}

- (void)setup
{
    [self.activityIndicator startAnimating];
}

@end
