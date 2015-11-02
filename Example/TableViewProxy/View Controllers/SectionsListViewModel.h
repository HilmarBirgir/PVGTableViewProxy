//
//  SectionsListViewModel.h
//  PVGTableViewProxyExample
//
//  Created by Alexander Annas Helgason on 25/10/15.
//  Copyright © 2015 Jóhann Þ. Bergþórsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVGTableViewCellViewModel.h"

@interface SectionsListViewModel : NSObject

@property (readonly, nonatomic) NSArray<NSObject<PVGTableViewCellViewModel> *> *yellowItems;
@property (readonly, nonatomic) NSArray<NSObject<PVGTableViewCellViewModel> *> *greenItems;

@end
