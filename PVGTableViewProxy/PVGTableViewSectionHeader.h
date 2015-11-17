//
//  PVGTableViewSectionHeader.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVGTableViewSectionHeaderViewModel.h"

@protocol PVGTableViewSectionHeader <NSObject>

@property (nullable, readwrite, atomic) id<PVGTableViewSectionHeaderViewModel> viewModel;

- (void)setup;

@optional

- (CGFloat)height;

@end