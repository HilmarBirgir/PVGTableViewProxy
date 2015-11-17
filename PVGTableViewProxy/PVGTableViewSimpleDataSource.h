//
//  PVGTableViewSimpleDataSource.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 08/10/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVGTableViewDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PVGTableViewSimpleDataSourceLoadMoreDelegate <NSObject>

- (void)loadMoreDataWithCurrentData:(NSArray<NSObject <PVGTableViewCellViewModel> *> *)currentData;

@end

@interface PVGTableViewSimpleDataSource : NSObject<PVGTableViewDataSource>

@property (readwrite, weak, atomic) id<PVGTableViewSimpleDataSourceLoadMoreDelegate> delegate;

+ (instancetype)dataSourceWithViewModels:(RACSignal *)source;

- (void)sendScrollCommand:(PVGTableViewScrollCommand *)scrollCommand;

@end

NS_ASSUME_NONNULL_END