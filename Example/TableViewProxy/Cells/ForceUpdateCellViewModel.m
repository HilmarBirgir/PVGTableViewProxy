//
//  ForceUpdateCellViewModel.m
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import "ForceUpdateCellViewModel.h"

NSString *const FORCE_UPDATE_CELL_REUSE_IDENTIFIER = @"ForceUpdateCell";

@interface ForceUpdateCellViewModel ()

@property (readwrite, nonatomic) NSString *ID;

@end

@implementation ForceUpdateCellViewModel

@synthesize sectionPosition = _sectionPosition;

- (instancetype)initWithID:(NSString *)ID;
{
    self = [super init];
    
    if (self)
    {
        self.ID = ID;
    }
    
    return self;
}

- (UIColor *)randomColor
{
    NSInteger random = arc4random() % 5;
    
    switch (random)
    {
        case 0:
            return [UIColor redColor];
            break;
            
        case 1:
            return [UIColor yellowColor];
            break;
            
        case 2:
            return [UIColor greenColor];
            break;
            
        case 3:
            return [UIColor blueColor];
            break;
            
        case 4:
            return [UIColor purpleColor];
            break;
            
        case 5:
            return [UIColor orangeColor];
            break;
            
        default:
            return [UIColor brownColor];
            break;
    }
    
}

#pragma mark - PVGTableViewCellViewModel

- (BOOL)forceUpdate
{
    return YES;
}

- (NSString *)reuseIdentifier
{
    return FORCE_UPDATE_CELL_REUSE_IDENTIFIER;
}

- (NSString *)uniqueID
{
    return [NSString stringWithFormat:@"forceupdatecell:%@", self.ID];
}

- (NSString *)cacheID
{
    return [NSString stringWithFormat:@"forceupdatecell:%@", self.ID];
}

- (NSString *)description
{
    return self.uniqueID;
}

@end
