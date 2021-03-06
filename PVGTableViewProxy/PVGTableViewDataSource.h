//
//  PVGTableViewDataSource.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 08/10/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVGTableViewCellViewModel.h"
#import "PVGTableViewScrollCommand.h"

NS_ASSUME_NONNULL_BEGIN

@class RACSignal;

@protocol PVGTableViewDataSource <NSObject>

@property (readonly, atomic) RACSignal *viewModels;

@property (readonly, atomic) RACSignal *errors;

@property (readonly, atomic) RACSignal *scrollCommands;

@optional

- (void)loadMoreDataWithCurrentData:(NSArray<NSObject <PVGTableViewCellViewModel> *> *)currentData;
- (void)reloadViewModels;

@end

NS_ASSUME_NONNULL_END