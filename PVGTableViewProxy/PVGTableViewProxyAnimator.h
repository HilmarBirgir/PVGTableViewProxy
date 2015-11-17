//
//  PVGTableViewProxyAnimator.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 13/11/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVGTableViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PVGTableViewProxyAnimator <NSObject>

// Returns an array of index paths that should be reloaded without animation.
- (NSArray<NSIndexPath *> *)animateWithTableView:(UITableView *)tableView
                                    sectionIndex:(NSInteger)sectionIndex
                                        lastData:(NSArray<NSObject <PVGTableViewCellViewModel> *> *)lastData
                                         newData:(NSArray<NSObject <PVGTableViewCellViewModel> *> *)newData;

@end

NS_ASSUME_NONNULL_END