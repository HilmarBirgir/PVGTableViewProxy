//
//  PVGGenericTableViewProxyAnimator.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 13/11/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVGTableViewProxyAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface PVGGenericTableViewProxyAnimator : NSObject<PVGTableViewProxyAnimator>

@property (readwrite, nonatomic) BOOL enableDebugAssertions;

@end


NS_ASSUME_NONNULL_END