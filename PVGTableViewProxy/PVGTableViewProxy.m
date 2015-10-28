//
//  PVGTableViewProxy.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 23/07/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "PVGTableViewProxy.h"

#import "PVGTableViewCellViewModel.h"
#import "PVGTableViewCell.h"
#import "PVGTableViewSectionHeader.h"

#import "PVGTableViewSimpleDataSource.h"
#import "PVGTableViewScrollCommand.h"
#import "PVGTableViewRenderCommand.h"

#import "PVGGenericTableViewProxyAnimator.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

NSInteger const LOAD_MORE_THRESHOLD = 15;
static BOOL enableDebugAssertions = NO;

@interface PVGTableViewProxy ()

// Making this weak fixes some leaks we see with TableViewProxys,
// but we do need to investigate this further.
@property (readwrite, atomic, weak) UITableView *tableView;

@property (readwrite, atomic) NSMutableArray *sections;
@property (readwrite, atomic) NSMutableDictionary *templateCells;
@property (readwrite, atomic) RACSubject *didReloadSubject;

@property (readwrite, atomic) RACTuple *pendingScrollCommand;
@property (readwrite, atomic) NSInteger ongoingScrollAnimations;
@property (readwrite, atomic) NSMutableArray *scrollCommandsQueue;

@property (readwrite, atomic) PVGTableViewRenderCommand *pendingRenderCommand;

@property (readwrite, atomic, weak) id<UITableViewDelegate> existingDelegate;

@end

@implementation PVGTableViewProxy

+ (void)turnDebugAssertionsOn
{
    enableDebugAssertions = YES;
}

+ (void)turnDebugAssertionsOff
{
    enableDebugAssertions = NO;
}

+ (instancetype)proxyWithTableView:(UITableView *)tableView
                        dataSource:(RACSignal *)dataSource
                           builder:(TableViewProxyBuilderBlock)builderBlock
{
    return [self proxyWithTableView:tableView builder:^(id<PVGTableViewProxyConfig> builder) {
        PVGTableViewSimpleDataSource *dataSourceWrapper = [PVGTableViewSimpleDataSource dataSourceWithViewModels:dataSource];
        [builder addSection:[PVGTableViewSection sectionWithDataSource:dataSourceWrapper] atIndex:0];
        builderBlock(builder);
    }];
}

+ (instancetype)proxyWithTableView:(UITableView *)tableView
                           builder:(TableViewProxyBuilderBlock)builderBlock
{
    PVGTableViewProxy *proxy = [[[self class] alloc] initWithTableView:tableView];
    builderBlock(proxy);
    
    proxy.existingDelegate = tableView.delegate;
    
    tableView.dataSource = proxy;
    tableView.delegate = proxy;
    
    return proxy;
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    
    if (self)
    {
        self.tableView = tableView;
        self.templateCells = [NSMutableDictionary dictionary];
        
        self.sections = [NSMutableArray array];
        
        self.didReloadSubject = [RACSubject subject];
        
        PVGGenericTableViewProxyAnimator *animator = [[PVGGenericTableViewProxyAnimator alloc] init];
        animator.enableDebugAssertions = enableDebugAssertions;
        self.animator = animator;
        
        self.scrollCommandsQueue = [NSMutableArray array];
    }
    
    return self;
}

- (void)executeRenderCommand:(PVGTableViewRenderCommand *)renderCommand
{
    if (self.ongoingScrollAnimations > 0)
    {
        self.pendingRenderCommand = renderCommand;
        return;
    }
    
    if (renderCommand)
    {
        [self updateSectionAtIndex:renderCommand.sectionIndex
                       withNewData:renderCommand.viewModels];
    }
    
    if (self.pendingScrollCommand)
    {
        RACTupleUnpack(NSNumber *sectionIndex, PVGTableViewScrollCommand *scrollCommand) = self.pendingScrollCommand;
        BOOL success = [self scrollInSection:[sectionIndex integerValue]
                                usingCommand:scrollCommand];
        if (success == YES)
        {
            self.pendingScrollCommand = nil;
        }
    }
}

- (void)setDataSource:(RACSignal *)dataSource
{
    PVGTableViewSimpleDataSource *dataSourceWrapper = [PVGTableViewSimpleDataSource dataSourceWithViewModels:dataSource];
    [self addSection:[PVGTableViewSection sectionWithDataSource:dataSourceWrapper] atIndex:0];
}

- (RACSignal *)didReload
{
    return self.didReloadSubject;
}

- (void)setupSingleSectionWithDataSource:(id<PVGTableViewDataSource>)dataSource
{
    [self addSection:[PVGTableViewSection sectionWithDataSource:dataSource] atIndex:0];
}

- (void)addSection:(PVGTableViewSection *)section atIndex:(NSInteger)sectionIndex
{
    if ([self.sections count] > sectionIndex)
    {
        self.sections[sectionIndex] = section;
    }
    else
    {
        [self.sections insertObject:section atIndex:sectionIndex];
    }
    @weakify(self);
    RACSignal *viewModelsSignal = [section.dataSource.viewModels ignore:nil];
    [viewModelsSignal subscribeNext:^(NSArray *newViewModels) {
        @strongify(self);
        [self executeRenderCommand:[PVGTableViewRenderCommand renderCommandForSection:sectionIndex
                                                                            viewModels:[newViewModels copy]]];
    }];
    
    [[section.dataSource.scrollCommands ignore:nil] subscribeNext:^(PVGTableViewScrollCommand *command) {
        @strongify(self);
        BOOL success = [self scrollInSection:sectionIndex usingCommand:command];
        self.pendingScrollCommand = success ? nil : RACTuplePack(@(sectionIndex), command);
    }];
}

- (void)updateSectionAtIndex:(NSInteger)sectionIndex
                 withNewData:(NSArray *)newData
{
    PVGTableViewSection *section = self.sections[sectionIndex];
    
    NSArray *lastData = section.loadedData;
    section.loadedData = newData;
    
    id<PVGTableViewCellViewModel> firstViewModel = [section.loadedData firstObject];
    firstViewModel.sectionPosition = TableViewCellPositionFirst;
    
    id<PVGTableViewCellViewModel> lastViewModel = [section.loadedData lastObject];
    lastViewModel.sectionPosition = TableViewCellPositionLast;
    
    NSArray *indexPathsToReloadWithNoAnimation = [self.animator animateWithTableView:self.tableView
                                                                        sectionIndex:sectionIndex
                                                                            lastData:lastData
                                                                             newData:section.loadedData];

    if ([indexPathsToReloadWithNoAnimation count] > 0)
    {
        for (NSIndexPath *indexPath in indexPathsToReloadWithNoAnimation)
        {
            UITableViewCell<PVGTableViewCell> *cell = (UITableViewCell<PVGTableViewCell> *)[self.tableView cellForRowAtIndexPath:indexPath];
            if (cell)
            {
                id<PVGTableViewCellViewModel> cellViewModel = [self viewModelForIndexPath:indexPath];
                
                cell = [self setupCell:cell viewModel:cellViewModel];
                
                [cell setNeedsLayout];
                [cell setNeedsDisplay];
            }
        }
    }
    
    [self.didReloadSubject sendNext:@YES];
}

- (void)registerClass:(Class)class forCellReuseIdentifier:(NSString *)identifier
{
    [self.tableView registerClass:class forCellReuseIdentifier:identifier];
    
    UITableViewCell<PVGTableViewCell> *templateCell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (templateCell)
    {
        self.templateCells[identifier] = templateCell;
    }
    else
    {
        NSLog(@"Error: Unable to dequeue template cell for identifier: %@", identifier);
    }
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
    
    UITableViewCell<PVGTableViewCell> *templateCell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    self.templateCells[identifier] = templateCell;
}

- (void)registerClass:(Class)headerClass forHeaderReuseIdentifier:(NSString *)identifier
{
    [self.tableView registerClass:headerClass forHeaderFooterViewReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forHeaderReuseIdentifier:(NSString *)identifier
{
    [self.tableView registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<PVGTableViewCellViewModel> cellViewModel = [self viewModelForIndexPath:indexPath];
    
    UITableViewCell<PVGTableViewCell> *cell = self.templateCells[cellViewModel.reuseIdentifier];
    
    [self attachViewModel:cellViewModel toCell:cell];
    
    CGFloat height = [cell.height floatValue];
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    PVGTableViewSection *section = self.sections[sectionIndex];
    if ([section.loadedData count] == 0)
    {
        return 0;
    }
    
    UITableViewHeaderFooterView<PVGTableViewSectionHeader> *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:section.reuseIdentifier];
    
    if ([headerView respondsToSelector:@selector(height)])
    {
        return headerView.height;
    }
    else
    {
        return headerView.frame.size.height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id<PVGTableViewCellViewModel> cellViewModel = [self viewModelForIndexPath:indexPath];
    
    if ([cellViewModel respondsToSelector:@selector(didSelectWithView:)])
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cellViewModel didSelectWithView:cell];
    }
    else if ([cellViewModel respondsToSelector:@selector(didSelect)])
    {
        [cellViewModel didSelect];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.existingDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)])
    {
        [self.existingDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
    
    UITableViewCell<PVGTableViewCell> *PVGTableViewCell = (UITableViewCell<PVGTableViewCell> *)cell;
    
    if ([PVGTableViewCell respondsToSelector:@selector(didEndDisplaying)])
    {
        [PVGTableViewCell didEndDisplaying];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.existingDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
    {
        [self.existingDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
    
    UITableViewCell<PVGTableViewCell> *PVGTableViewCell = (UITableViewCell<PVGTableViewCell> *)cell;
    if ([PVGTableViewCell respondsToSelector:@selector(willDisplay)])
    {
        [PVGTableViewCell willDisplay];
    }
    
    PVGTableViewSection *section = self.sections[indexPath.section];
    if (indexPath.row + LOAD_MORE_THRESHOLD >= [[section loadedData] count])
    {
        // We can't to this inline because telling a section to laod more data may trigger an syncronous
        // update to the table view in a place where it isn't supported.
        dispatch_async(dispatch_get_main_queue(), ^{
            [section loadMoreData];
        });
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex < [self.sections count])
    {
        PVGTableViewSection *section = self.sections[sectionIndex];
        return [section.loadedData count];
    }
    else
    {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex
{
    PVGTableViewSection *section = self.sections[sectionIndex];
    return section.sectionHeaderViewModel.title;
}

- (id<PVGTableViewCellViewModel>)viewModelForIndexPath:(NSIndexPath *)indexPath
{
    PVGTableViewSection *section = self.sections[indexPath.section];
    return section.loadedData[indexPath.row];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    PVGTableViewSection *section = self.sections[sectionIndex];
    
    UITableViewHeaderFooterView<PVGTableViewSectionHeader> *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:section.reuseIdentifier];
    headerView.viewModel = section.sectionHeaderViewModel;
    
    [headerView setup];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<PVGTableViewCellViewModel> cellViewModel = [self viewModelForIndexPath:indexPath];
    
    UITableViewCell<PVGTableViewCell> *cell = [tableView dequeueReusableCellWithIdentifier:cellViewModel.reuseIdentifier];
    
    cell = [self setupCell:cell
                 viewModel:cellViewModel];
    
    return cell;
}

- (void)attachViewModel:(id<PVGTableViewCellViewModel>)cellViewModel toCell:(UITableViewCell<PVGTableViewCell> *)cell
{
    // In order to make sure that cell can depend on their frame calculations to be correct.
    CGRect frame = cell.frame;
    frame.size.width = self.tableView.frame.size.width;
    cell.frame = frame;
    
    cell.viewModel = cellViewModel;
}

- (UITableViewCell<PVGTableViewCell> *)setupCell:(UITableViewCell<PVGTableViewCell> *)cell
                                    viewModel:(id<PVGTableViewCellViewModel>)cellViewModel
{
    [self attachViewModel:cellViewModel toCell:cell];
    
    [cell setup];
    
    return cell;
}

#pragma mark - Scrolling

- (BOOL)scrollInSection:(NSInteger)sectionIndex
           usingCommand:(PVGTableViewScrollCommand *)command
{
    if (command == nil)
    {
        return YES; // No scroll command means successful scroll :troll:
    }
    
    if (sectionIndex >= [self.sections count] || sectionIndex < 0)
    {
        return NO;
    }
    
    PVGTableViewSection *section = self.sections[sectionIndex];
    NSArray *viewModelsInSection = section.loadedData;
    
    UITableViewScrollPosition scrollPosition = UITableViewScrollPositionMiddle;
    NSIndexPath *indexPath;
    switch (command.type)
    {
        case ScrollCommandTypeTop:
        {
            scrollPosition = UITableViewScrollPositionTop;
            indexPath = [NSIndexPath indexPathForRow:0
                                           inSection:sectionIndex];
            break;
        }
            
        case ScrollCommandTypeBottom:
        {
            scrollPosition = UITableViewScrollPositionBottom;
            indexPath = [NSIndexPath indexPathForRow:[viewModelsInSection count] - 1
                                           inSection:sectionIndex];
            break;
        }
            
        case ScrollCommandTypeItem:
        {
            scrollPosition = UITableViewScrollPositionMiddle;
            NSInteger indexOfRow = 0;
            for (id<PVGTableViewCellViewModel> viewModel in viewModelsInSection)
            {
                if ([[viewModel uniqueID] isEqualToString:command.uniqueID])
                {
                    break;
                }
                
                indexOfRow++;
            }
            
            if (indexOfRow < [viewModelsInSection count])
            {
                indexPath = [NSIndexPath indexPathForRow:indexOfRow inSection:sectionIndex];
            }
            break;
        }
    }
    
    if (indexPath == nil)
    {
        return NO;
    }
    
    if (self.ongoingScrollAnimations > 0)
    {
        [self.scrollCommandsQueue addObject:RACTuplePack(@(sectionIndex), command)];
        return YES;
    }
    
    if (indexPath.row >= [viewModelsInSection count])
    {
        return YES;
    }
    
    // There is no reliable way to know when a scroll animation has ended in UIKit.
    // Because we want to serialize all scroll animations we need to be able to keep a ledger
    // we first need to scroll without animation, check if there will be some movement
    // and then reset the content offset and kick off the actual animation. FUN TIMES!
    CGFloat originalOffset = self.tableView.contentOffset.y;
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:NO];
    CGFloat offset = self.tableView.contentOffset.y;
    
    if (originalOffset != offset)
    {
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, originalOffset) animated:NO];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:scrollPosition
                                      animated:command.animated];
        if (command.animated)
        {
            self.ongoingScrollAnimations++;
        }
    }
    
    return YES;
}

#pragma mark - Forwarding Delegate methods

// What we are doing here is making sure that if the table view that we get passed in already has a delegate that we fire the delegate methods
// along side ours if table view proxy implements them and just forward them if it doesn't implement them.
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.existingDelegate respondsToSelector:aSelector] && [super respondsToSelector:aSelector] == NO)
    {
        return self.existingDelegate;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self.existingDelegate respondsToSelector:aSelector])
    {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.existingDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
    {
        [self.existingDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
    
    self.ongoingScrollAnimations--;
    if (self.ongoingScrollAnimations < 0)
    {
        self.ongoingScrollAnimations = 0;
    }
    
    if ([self.sections count] > 0)
    {
        if ([self.scrollCommandsQueue count] > 0)
        {
            RACTupleUnpack(NSNumber *sectionIndex, PVGTableViewScrollCommand *command) = self.scrollCommandsQueue[0];
            [self.scrollCommandsQueue removeObjectAtIndex:0];
            
            [self scrollInSection:[sectionIndex integerValue] usingCommand:command];
        }
        else if (self.pendingRenderCommand)
        {
            [self updateSectionAtIndex:self.pendingRenderCommand.sectionIndex withNewData:self.pendingRenderCommand.viewModels];
            self.pendingRenderCommand = nil;
        }
    }
}

#pragma mark - Helper

- (UITableViewCell<PVGTableViewCell> *)templateCellForReuseIdentifier:(NSString *)reuseIdentifier;
{
    return self.templateCells[reuseIdentifier];
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

@end