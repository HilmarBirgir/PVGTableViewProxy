//
//  ManualUpdateListViewModel.m
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "ForceUpdateListViewModel.h"

#import "ForceUpdateCellViewModel.h"

@interface ForceUpdateListViewModel ()

@property (readwrite, nonatomic) NSArray *items;

@end

@implementation ForceUpdateListViewModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        NSMutableArray *items = [NSMutableArray array];
        
        for (NSInteger i = 0; i != 100; i++)
        {
            ForceUpdateCellViewModel *cellViewModel = [[ForceUpdateCellViewModel alloc] initWithID:[NSString stringWithFormat:@"%@", @(i)]];
            [items addObject:cellViewModel];
        }
        
        self.items = [items copy];
    }
    
    return self;
}

@end
