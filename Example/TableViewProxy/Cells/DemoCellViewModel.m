//
//  DemoCellViewModel.m
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "DemoCell.h"

NSString *const DEMO_CELL_REUSE_IDENTIFIER = @"DemoCell";

@interface DemoCellViewModel ()

@property (readwrite, nonatomic) UIColor *color;
@property (readwrite, nonatomic) NSString *ID;

@end

@implementation DemoCellViewModel

@synthesize sectionPosition = _sectionPosition;

- (instancetype)initWithID:(NSString *)ID
                     color:(UIColor *)color
{
    self = [super init];
    
    if (self)
    {
        self.ID = ID;
        self.color = color;
    }
    
    return self;
}

#pragma mark - PVGTableViewCellViewModel

- (NSString *)reuseIdentifier
{
    return DEMO_CELL_REUSE_IDENTIFIER;
}

- (NSString *)uniqueID
{
    return [NSString stringWithFormat:@"democell:%@", self.ID];
}

- (NSString *)cacheID
{
    return [NSString stringWithFormat:@"democell:%@", self.ID];
}

- (NSString *)description
{
    return self.uniqueID;
}

@end
