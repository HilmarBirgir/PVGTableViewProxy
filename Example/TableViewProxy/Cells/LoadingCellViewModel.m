//
//  LoadingCellViewModel.m
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "LoadingCell.h"

NSString *const LOADING_CELL_REUSE_IDENTIFIER = @"LoadingCell";

@interface LoadingCellViewModel ()

@property (readwrite, nonatomic) NSString *ID;

@end

@implementation LoadingCellViewModel

@synthesize sectionPosition = _sectionPosition;

- (instancetype)initWithID:(NSString *)ID
{
    self = [super init];
    
    if (self)
    {
        self.ID = ID;
    }
    
    return self;
}

#pragma mark - PVGTableViewCellViewModel

- (NSString *)reuseIdentifier
{
    return LOADING_CELL_REUSE_IDENTIFIER;
}

- (NSString *)cacheID
{
    return [NSString stringWithFormat:@"loading-%@", self.ID];;
}

- (NSString *)uniqueID
{
    return [NSString stringWithFormat:@"loading-%@", self.ID];
}

- (NSString *)description
{
    return self.uniqueID;
}

@end
