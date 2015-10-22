//
//  DemoCellViewModel.h
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <PVGTableViewCellViewModel.h>

FOUNDATION_EXPORT NSString *const DEMO_CELL_REUSE_IDENTIFIER;

@interface DemoCellViewModel : NSObject<PVGTableViewCellViewModel>

@property (readonly, nonatomic) UIColor *color;
@property (readonly, nonatomic) NSString *ID;

- (instancetype)initWithID:(NSString *)ID
                     color:(UIColor *)color;

@end
