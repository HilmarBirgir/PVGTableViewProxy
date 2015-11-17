//
//  RefreshTableViewProxyAnimator.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 30/11/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "PVGNoAnimationTableViewProxyAnimator.h"

@implementation PVGNoAnimationTableViewProxyAnimator

- (NSArray<NSIndexPath *> *)animateWithTableView:(UITableView *)tableView
                                    sectionIndex:(NSInteger)sectionIndex
                                        lastData:(NSArray<NSObject <PVGTableViewCellViewModel> *> *)lastData
                                         newData:(NSArray<NSObject <PVGTableViewCellViewModel> *> *)newData
{
    [tableView reloadData];
    return @[];
}

@end
