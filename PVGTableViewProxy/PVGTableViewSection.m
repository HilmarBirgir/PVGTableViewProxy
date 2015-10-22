//
//  PVGTableViewSection.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "PVGTableViewSection.h"

@interface PVGTableViewSection ()

@property (readwrite, atomic, copy) NSString *reuseIdentifier;
@property (readwrite, atomic) id<PVGTableViewSectionHeaderViewModel> sectionHeaderViewModel;
@property (readwrite, atomic) id<PVGTableViewDataSource> dataSource;

@end

@implementation PVGTableViewSection

+ (instancetype)sectionWithDataSource:(id<PVGTableViewDataSource>)dataSource
{
    PVGTableViewSection *section = [[[self class] alloc] init];
    section.dataSource = dataSource;
    
    return section;
}

+ (instancetype)sectionWithReuseIdentifier:(NSString *)reuseIdentifier
                                     title:(NSString *)title
                                dataSource:(id<PVGTableViewDataSource>)dataSource
{
    PVGTableViewSection *section = [[[self class] alloc] init];
    section.reuseIdentifier = reuseIdentifier;
    section.sectionHeaderViewModel = [PVGTableViewSectionHeaderViewModel viewModelWithTitle:title];
    section.dataSource = dataSource;
    
    return section;
}

+ (instancetype)sectionWithReuseIdentifier:(NSString *)reuseIdentifier
                    sectionHeaderViewModel:(id<PVGTableViewSectionHeaderViewModel>)sectionHeaderViewModel
                                dataSource:(id<PVGTableViewDataSource>)dataSource
{
    PVGTableViewSection *section = [[[self class] alloc] init];
    section.reuseIdentifier = reuseIdentifier;
    section.sectionHeaderViewModel = sectionHeaderViewModel;
    section.dataSource = dataSource;
    
    return section;
}

- (void)loadMoreData
{
    if (self.loadedData && [self.dataSource respondsToSelector:@selector(loadMoreDataWithCurrentData:)])
    {
        [self.dataSource loadMoreDataWithCurrentData:self.loadedData];
    }
}

@end
