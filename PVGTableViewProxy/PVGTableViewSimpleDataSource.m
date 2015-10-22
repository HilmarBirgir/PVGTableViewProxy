//
//  PVGTableViewSimpleDataSource.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 08/10/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "PVGTableViewSimpleDataSource.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PVGTableViewSimpleDataSource ()

@property (readwrite, atomic) RACSignal *viewModels;
@property (readwrite, atomic) RACSignal *errors;

@property (readwrite, atomic) RACSubject *scrollCommandsEmitter;

@end

@implementation PVGTableViewSimpleDataSource

+ (instancetype)dataSourceWithViewModels:(RACSignal *)viewModels
{
    return [[[self class] alloc] initWithViewModels:viewModels];
}

- (instancetype)initWithViewModels:(RACSignal *)viewModels
{
    self = [super init];
    
    if (self)
    {
        self.viewModels = viewModels;
        self.scrollCommandsEmitter = [RACSubject subject];
    }
    
    return self;
}

- (RACSignal *)scrollCommands
{
    return self.scrollCommandsEmitter;
}

- (void)loadMoreDataWithCurrentData:(NSArray *)currentData
{
    [self.delegate loadMoreDataWithCurrentData:currentData];
}

- (void)sendScrollCommand:(PVGTableViewScrollCommand *)scrollCommand
{
    [self.scrollCommandsEmitter sendNext:scrollCommand];
}

@end
