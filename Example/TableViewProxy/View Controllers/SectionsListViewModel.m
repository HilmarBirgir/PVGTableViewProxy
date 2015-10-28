//
//  SectionsListViewModel.m
//  PVGTableViewProxyExample
//
//  Created by Alexander Annas Helgason on 25/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "SectionsListViewModel.h"

#import "DemoCellViewModel.h"

static NSInteger NUM_YELLOW_ITEMS = 10;
static NSInteger NUM_GREEN_ITMES = 5;

@interface SectionsListViewModel ()

@property (readwrite, nonatomic) NSArray<NSObject<PVGTableViewCellViewModel> *> *yellowItems;
@property (readwrite, nonatomic) NSArray<NSObject<PVGTableViewCellViewModel> *> *greenItems;

@end

@implementation SectionsListViewModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self createYellowItems];
        [self createGreenItems];
    }
    
    return self;
}

- (void)createYellowItems
{
    NSMutableArray *yellowItems = [NSMutableArray array];
    
    for (NSInteger i = 0; i < NUM_YELLOW_ITEMS; i++)
    {
        DemoCellViewModel *cellViewModel = [[DemoCellViewModel alloc] initWithID:[NSString stringWithFormat:@"%@", @(i)]
                                                                           color:[UIColor yellowColor]];
        
        [yellowItems addObject:cellViewModel];
    }
    
    self.yellowItems = yellowItems;
}

- (void)createGreenItems
{
    NSMutableArray *greenItems = [NSMutableArray array];
    
    for (NSInteger i = 0; i < NUM_GREEN_ITMES; i++)
    {
        DemoCellViewModel *cellViewModel = [[DemoCellViewModel alloc] initWithID:[NSString stringWithFormat:@"%@", @(i)]
                                                                           color:[UIColor greenColor]];
        
        [greenItems addObject:cellViewModel];
    }
    
    self.greenItems = greenItems;
}

@end
