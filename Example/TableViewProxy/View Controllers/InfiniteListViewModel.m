//
//  InfinitePagingExampleSceneViewModel.m
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "InfiniteListViewModel.h"

#import "DemoCellViewModel.h"
#import "LoadingCellViewModel.h"

static NSInteger NUMBER_PER_PAGE = 20;

@interface InfiniteListViewModel ()

@property (readwrite, nonatomic) BOOL loading;
@property (readwrite, nonatomic) NSArray *items;

@end

@implementation InfiniteListViewModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.items = [self generateItemsFromStartIndex:0];
        self.shouldLoadSync = YES;
    }
    
    return self;
}

- (NSArray *)generateItemsFromStartIndex:(NSInteger)startIndex
{
    NSMutableArray *items = [NSMutableArray array];

    for (NSInteger i = 0; i != NUMBER_PER_PAGE; i++)
    {
        DemoCellViewModel *cellViewModel = [[DemoCellViewModel alloc] initWithID:[NSString stringWithFormat:@"%@", @(i + startIndex)]
                                                                           color:i % 2 == 0 ? [UIColor yellowColor] : [UIColor greenColor]];
        
        [items addObject:cellViewModel];
    }
    
    return [items copy];
}

- (void)loadMoreData
{
    if (self.loading)
    {
        return;
    }
    
    self.loading = YES;
    [self addLoadingIndicator];
    
    if (self.shouldLoadSync)
    {
        [self loadSync];
    }
    else
    {
        [self loadAsync];
    }
}

- (void)addLoadingIndicator
{
    NSMutableArray *items = [self.items mutableCopy];
    [items addObject:[[LoadingCellViewModel alloc] initWithID:[NSString stringWithFormat:@"%@", @([self.items count])]]];

    self.items = items;
}

- (void)removeLoadingIndicator
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items];
    [items removeLastObject];
    self.items = items;
}

- (void)loadMore
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items];
    [items removeLastObject];
    [items addObjectsFromArray:[self generateItemsFromStartIndex:[items count]]];
    
    self.items = items;
    self.loading = NO;
}

- (void)loadSync
{
    [self loadMore];
}

- (void)loadAsync
{
    [self performSelector:@selector(loadMore) withObject:nil afterDelay:2];
}

@end
