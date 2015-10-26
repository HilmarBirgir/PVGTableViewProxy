//
//  PVGTableViewRenderCommand.m
//  
//
//  Created by Jóhann Þorvaldur Bergþórsson on 26/10/15.
//
//

#import "PVGTableViewRenderCommand.h"

@interface PVGTableViewRenderCommand ()

@property (readwrite, nonatomic) NSInteger sectionIndex;
@property (readwrite, nonatomic) NSArray<NSObject <PVGTableViewCellViewModel> *> *viewModels;

@end

@implementation PVGTableViewRenderCommand

+ (instancetype)renderCommandForSection:(NSInteger)sectionIndex
                             viewModels:(NSArray<NSObject <PVGTableViewCellViewModel> *> *)viewModels
{
    PVGTableViewRenderCommand *command = [PVGTableViewRenderCommand new];
    command.sectionIndex = sectionIndex;
    command.viewModels = viewModels;
    return command;
}

@end
