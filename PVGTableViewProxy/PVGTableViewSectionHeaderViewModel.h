//
//  PVGTableViewSectionHeaderViewModel.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 24/09/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PVGTableViewSectionHeaderViewModel <NSObject>

@property (readonly, atomic, copy) NSString *title;

@end

@interface PVGTableViewSectionHeaderViewModel : NSObject<PVGTableViewSectionHeaderViewModel>

+ (instancetype)viewModelWithTitle:(NSString *)title;

@end
