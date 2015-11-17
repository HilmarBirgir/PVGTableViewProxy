//
//  PVGTableViewProxy.h
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 23/07/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "PVGTableViewCell.h"

#import "PVGTableViewSection.h"
#import "PVGTableViewProxyAnimator.h"

@class RACSignal;
@class PVGTableViewProxy;

NS_ASSUME_NONNULL_BEGIN

@protocol PVGTableViewProxyConfig <NSObject>

- (void)registerClass:(Class)headerClass forHeaderReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forHeaderReuseIdentifier:(NSString *)identifier;

- (void)registerClass:(Class)class forCellReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;

- (void)setupSingleSectionWithDataSource:(id<PVGTableViewDataSource>)dataSource;
- (void)addSection:(PVGTableViewSection *)section atIndex:(NSInteger)sectionIndex;

@end

typedef void (^TableViewProxyBuilderBlock)(id<PVGTableViewProxyConfig> builder);

@interface PVGTableViewProxy : NSObject<UITableViewDataSource, UITableViewDelegate, PVGTableViewProxyConfig>

@property (readonly, atomic) RACSignal *didReload;
@property (readwrite, atomic) id<PVGTableViewProxyAnimator> animator;

// Enables stronger assertions to help debug rendering issues. Comes with a slight performance hit.
+ (void)turnDebugAssertionsOn;
+ (void)turnDebugAssertionsOff;

/*
 Example usage:
 
 PVGTableViewProxy *dataSource = [PVGTableViewProxy proxyWithTableView:self.newsFeed
 dataSource:self.viewModel.feedStream
 builder:^(id<PVGTableViewProxyConfig> builder) {
 UINib *nib = [UINib nibWithNibName:@"FeedItemCell" bundle:nil];
 [builder registerNib:nib forCellReuseIdentifier:GAME_ITEM_REUSE_IDENTIFIER];
 [builder registerNib:nib forCellReuseIdentifier:PROFILE_PICTURE_CHANGE_ITEM_REUSE_IDENTIFIER];
 [builder registerNib:nib forCellReuseIdentifier:QUESTIONS_ADDED_ITEM_REUSE_IDENTIFIER];
 [builder registerNib:nib forCellReuseIdentifier:ACHIEVEMENT_ITEM_REUSE_IDENTIFIER];
 }];
 */
+ (instancetype)proxyWithTableView:(UITableView *)tableView
                        dataSource:(RACSignal *)sourceSignal
                           builder:(TableViewProxyBuilderBlock)builderBlock;

/*
 Example usage:
 
 PVGTableViewProxy *dataSource = [PVGTableViewProxy proxyWithTableView:self.newsFeed
 builder:^(id<PVGTableViewProxyConfig> builder) {
 
 [builder addDataSource:firstSectionDataSource forSection:0];
 [builder addDataSource:secondSectionDataSource forSection:1];
 
 UINib *nib = [UINib nibWithNibName:@"FeedItemCell" bundle:nil];
 [builder registerNib:nib forCellReuseIdentifier:GAME_ITEM_REUSE_IDENTIFIER];
 [builder registerNib:nib forCellReuseIdentifier:PROFILE_PICTURE_CHANGE_ITEM_REUSE_IDENTIFIER];
 }];
 */
+ (instancetype)proxyWithTableView:(UITableView *)tableView
                           builder:(TableViewProxyBuilderBlock)builderBlock;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (void)setDataSource:(RACSignal *)dataSource;

- (UITableViewCell<PVGTableViewCell> *)templateCellForReuseIdentifier:(NSString *)reuseIdentifier;

- (id<PVGTableViewCellViewModel>)viewModelForIndexPath:(NSIndexPath *)indexPath;
- (void)attachViewModel:(id<PVGTableViewCellViewModel>)cellViewModel toCell:(UITableViewCell<PVGTableViewCell> *)cell;

@end

NS_ASSUME_NONNULL_END