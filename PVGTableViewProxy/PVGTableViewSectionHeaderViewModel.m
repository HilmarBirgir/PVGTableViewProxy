//
//  PVGTableViewSectionHeaderViewModel.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 24/09/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "PVGTableViewSectionHeaderViewModel.h"

@interface PVGTableViewSectionHeaderViewModel ()

@property (readwrite, atomic, copy) NSString *title;

@end

@implementation PVGTableViewSectionHeaderViewModel

+ (instancetype)viewModelWithTitle:(NSString *)title
{
    PVGTableViewSectionHeaderViewModel *viewModel = [[[self class] alloc] init];
    viewModel.title = title;
    return viewModel;
}

@end
