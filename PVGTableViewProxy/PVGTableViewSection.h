//
//  PVGTableViewSection.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVGTableViewSectionHeaderViewModel.h"
#import "PVGTableViewDataSource.h"
#import "PVGTableViewSimpleDataSource.h"

@class RACSignal;

@protocol PVGTableViewSectionDataSource <NSObject>

@property (readonly, atomic) RACSignal *dataSource;

- (void)loadMoreDataWithCurrentData:(NSArray *)currentData;

@end

@interface PVGTableViewSection : NSObject

@property (readonly, atomic, copy) NSString *reuseIdentifier;

@property (readonly, atomic) id<PVGTableViewSectionHeaderViewModel> sectionHeaderViewModel;

@property (readonly, atomic) id<PVGTableViewDataSource> dataSource;
@property (readwrite, atomic, copy) NSArray *loadedData;

+ (instancetype)sectionWithDataSource:(id<PVGTableViewDataSource>)dataSource;

+ (instancetype)sectionWithReuseIdentifier:(NSString *)reuseIdentifier
                                     title:(NSString *)title
                                dataSource:(id<PVGTableViewDataSource>)dataSource;

+ (instancetype)sectionWithReuseIdentifier:(NSString *)reuseIdentifier
                    sectionHeaderViewModel:(id<PVGTableViewSectionHeaderViewModel>)sectionHeaderViewModel
                                dataSource:(id<PVGTableViewDataSource>)dataSource;

- (void)loadMoreData;

@end
