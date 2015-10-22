//
//  PVGTableViewProxyAnimator.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 13/11/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PVGTableViewProxyAnimator <NSObject>

// Returns an array of index paths that should be reloaded without animation.
- (NSArray *)animateWithTableView:(UITableView *)tableView
                sectionIndex:(NSInteger)sectionIndex
                    lastData:(NSArray *)lastData
                     newData:(NSArray *)newData;

@end
