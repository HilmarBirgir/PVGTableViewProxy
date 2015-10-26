//
//  PVGTableViewRenderCommand.h
//  
//
//  Created by Jóhann Þorvaldur Bergþórsson on 26/10/15.
//
//

#import <Foundation/Foundation.h>
#import "PVGTableViewCellViewModel.h"

@interface PVGTableViewRenderCommand : NSObject

@property (readonly, nonatomic) NSInteger sectionIndex;
@property (readonly, nonatomic) NSArray<NSObject <PVGTableViewCellViewModel> *> *viewModels;

+ (instancetype)renderCommandForSection:(NSInteger)sectionIndex
                             viewModels:(NSArray<NSObject <PVGTableViewCellViewModel> *> *)viewModels;

@end
