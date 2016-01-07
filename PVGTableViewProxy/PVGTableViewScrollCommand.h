//
//  PVGTableViewScrollCommand.h.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 17/02/15.
//  Copyright (c) 2015 Plain Vanilla Games. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ScrollCommandType) {
    ScrollCommandTypeTop,
    ScrollCommandTypeBottom,
    ScrollCommandTypeItem,
};

NS_ASSUME_NONNULL_BEGIN

@interface PVGTableViewScrollCommand : NSObject

@property (readonly, nonatomic) ScrollCommandType type;
@property (readonly, nonatomic, copy, nullable) NSString *uniqueID;
@property (readonly, nonatomic) BOOL animated;

+ (instancetype)commandWithType:(ScrollCommandType)type
                       animated:(BOOL)animated
                       uniqueID:(nullable NSString *)uniqueID;

@end

NS_ASSUME_NONNULL_END