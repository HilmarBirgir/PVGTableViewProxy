//
//  ForceUpdateCellViewModel.h
//  PVGTableViewProxyExample
//
//  Created by Hilmar Birgir Ólafsson on 21/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <PVGTableViewProxy/PVGTableViewCellViewModel.h>

FOUNDATION_EXPORT NSString *const FORCE_UPDATE_CELL_REUSE_IDENTIFIER;

@interface ForceUpdateCellViewModel : NSObject<PVGTableViewCellViewModel>

@property (readonly, nonatomic) NSString *ID;

- (instancetype)initWithID:(NSString *)ID;

- (UIColor *)randomColor;

@end
