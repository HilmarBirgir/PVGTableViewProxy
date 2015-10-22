//
//  StaticExampleSceneViewModel.m
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "StaticListViewModel.h"

#import "DemoCellViewModel.h"

@interface StaticListViewModel ()

@property (readwrite, nonatomic) NSArray *items;

@end

@implementation StaticListViewModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        NSMutableArray *items = [NSMutableArray array];

        for (NSInteger i = 0; i != 100; i++)
        {
            DemoCellViewModel *cellViewModel = [[DemoCellViewModel alloc] initWithID:[NSString stringWithFormat:@"%@", @(i)]
                                                                               color:i % 2 == 0 ? [UIColor yellowColor] : [UIColor greenColor]];
            [items addObject:cellViewModel];
        }
        
        self.items = [items copy];
    }
    
    return self;
}

@end
