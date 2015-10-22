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

@class RACSignal;

@protocol PVGTableViewDataSource <NSObject>

@property (readonly, atomic) RACSignal *viewModels;

@property (readonly, atomic) RACSignal *errors;

@property (readonly, atomic) RACSignal *scrollCommands;

@optional

- (void)loadMoreDataWithCurrentData:(NSArray *)currentData;
- (void)reloadViewModels;

@end
