//
//  PVGTableViewCell.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 25/07/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "PVGTableViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PVGTableViewCell <NSObject>

@property (nullable, readwrite, nonatomic) id<PVGTableViewCellViewModel> viewModel;

- (NSNumber *)height;
- (void)setup;

@optional

- (void)didEndDisplaying;
- (void)willDisplay;

@end

NS_ASSUME_NONNULL_END