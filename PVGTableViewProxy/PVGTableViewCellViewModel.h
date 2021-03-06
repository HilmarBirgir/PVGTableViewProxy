//
//  PVGTableViewCellViewModel.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 25/07/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//
#import <UIKit/UIKit.h>

@class RACSignal;

typedef NS_ENUM(NSUInteger, TableViewCellPosition) {
    TableViewCellPositionMiddle = 0,
    TableViewCellPositionFirst,
    TableViewCellPositionLast
};

NS_ASSUME_NONNULL_BEGIN

@protocol PVGTableViewCellViewModel <NSObject>

@property (readonly, atomic, copy) NSString *reuseIdentifier;
@property (readonly, atomic, copy) NSString *uniqueID;
@property (readonly, atomic, copy) NSString *cacheID;

@property (readwrite, atomic) TableViewCellPosition sectionPosition;

@optional

- (void)didSelect;
- (void)didSelectWithView:(UIView *)sourceView;
// There are cases where we need to trigger an action sheet and then we need the actual source view for iPad
// It doesn't feel super nice but it is an easy solution.

/**
 *  Returns true if for any reason the cell needs to be force updated.
 *
 *  @return a boolean indicateting that the view should be forced updated.
 */
- (BOOL)forceUpdate;

@end

@protocol PVGTableViewCellSeperatorProtocol <NSObject>

@property (readwrite, nonatomic) BOOL forceHideSeparator;

@end

NS_ASSUME_NONNULL_END