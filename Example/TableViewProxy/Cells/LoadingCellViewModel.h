//
//  LoadingCellViewModel.h
//  PVGTableViewProxy
//
//  Created by Jóhann Þorvaldur Bergþórsson on 20/09/15.
//  Copyright (c) 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <PVGTableViewCellViewModel.h>

FOUNDATION_EXPORT NSString *const LOADING_CELL_REUSE_IDENTIFIER;

@interface LoadingCellViewModel : NSObject<PVGTableViewCellViewModel>

- (instancetype)initWithID:(NSString *)ID;

@end
