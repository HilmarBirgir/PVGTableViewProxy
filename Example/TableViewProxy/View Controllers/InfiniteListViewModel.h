//
//  InfinitePagingExampleSceneViewModel.h
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfiniteListViewModel : NSObject

@property (readonly, nonatomic) NSArray *items;
@property (readwrite, nonatomic) BOOL shouldLoadSync;

- (void)loadMoreData;

@end
