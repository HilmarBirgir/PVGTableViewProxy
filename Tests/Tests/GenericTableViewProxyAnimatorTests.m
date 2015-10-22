//
//  GenericTableViewProxyAnimatorTests.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 13/11/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//


#import "TestDependencies.h"

#import "PVGGenericTableViewProxyAnimator.h"
#import "PVGTableViewCellViewModel.h"


@interface GenericTableViewProxyAnimatorTests : XCTestCase

@property (readwrite, atomic) id mockTableView;
@property (readwrite, atomic) PVGGenericTableViewProxyAnimator *animator;

@end

@implementation GenericTableViewProxyAnimatorTests

- (NSArray *)viewModelsFromCacheIDs:(NSArray *)templates
{
    NSMutableArray *viewModels = [NSMutableArray array];
    for (RACTuple *uniqueID_cacheID in templates)
    {
        RACTupleUnpack(NSString *uniqueID, NSString *cacheID) = uniqueID_cacheID;
        
        id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
        OCMStub([mockViewModel cacheID]).andReturn(cacheID);
        OCMStub([mockViewModel uniqueID]).andReturn(uniqueID);
        
        [viewModels addObject:mockViewModel];
    }
    return viewModels;
}

- (void)setUp
{
    [super setUp];

    self.mockTableView = OCMClassMock([UITableView class]);
    
    NSValue *value = [NSValue valueWithCGPoint:CGPointZero];
    OCMStub([self.mockTableView contentOffset]).andReturn(value);
    
    self.animator = [[PVGGenericTableViewProxyAnimator alloc] init];
}

- (void)test_inserts_all_with_no_animation_if_no_rows_before_animation
{

    NSArray *lastData = @[];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerify([self.mockTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone]);
}

- (void)test_removes_all_with_fade_animation_if_removing_all_rows
{
    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    NSArray *newData = @[];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerify([self.mockTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);
}

- (void)test_reloads_all_rows_with_no_animation_that_have_changed_cache_id_but_have_same_unique_id
{
    OCMExpect([self.mockTableView beginUpdates]);
    OCMExpect([self.mockTableView endUpdates]);
    
    [[[self.mockTableView reject] ignoringNonObjectArgs] setContentOffset:CGPointZero animated:NO];

    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2b")]];
    
    NSArray *reloadedWithoutAnimation = [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    XCTAssertEqualObjects(reloadedWithoutAnimation, @[[NSIndexPath indexPathForItem:1 inSection:0]]);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_does_nothing_for_rows_with_same_cache_id_and_unique_id
{
    [[self.mockTableView reject] beginUpdates];
    [[self.mockTableView reject] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[[self.mockTableView reject] ignoringNonObjectArgs] setContentOffset:CGPointZero animated:NO];
    [[self.mockTableView reject] endUpdates];
    
    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    [self.mockTableView verify];
}

- (void)test_reloads_with_correct_animation_if_just_shuffling
{
    OCMExpect([self.mockTableView beginUpdates]);
    
    NSArray *insertIndexPaths = @[
                            [NSIndexPath indexPathForItem:0 inSection:0],
                            [NSIndexPath indexPathForItem:1 inSection:0]
                            ];
    OCMExpect([self.mockTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight]);
    
    NSArray *deleteInsertPaths = @[
                                   [NSIndexPath indexPathForItem:0 inSection:0],
                                   [NSIndexPath indexPathForItem:1 inSection:0]
                                   ];
    
    OCMExpect([self.mockTableView deleteRowsAtIndexPaths:deleteInsertPaths withRowAnimation:UITableViewRowAnimationFade]);
    OCMExpect([self.mockTableView endUpdates]);

    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"B", @"2"), RACTuplePack(@"A", @"1")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_insert_all_rows_at_start_with_right_animation_if_new_data_is_adding_to_start
{
    OCMExpect([self.mockTableView beginUpdates]);

    NSArray *insertIndexPaths = @[[NSIndexPath indexPathForItem:0 inSection:0]];
    
    OCMExpect([self.mockTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight]);
    OCMExpect([self.mockTableView endUpdates]);

    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"C", @"3"), RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_removes_correct_row_if_just_removing_in_middle
{
    OCMExpect([self.mockTableView beginUpdates]);
    
    NSArray *deleteIndexPahts = @[[NSIndexPath indexPathForItem:1 inSection:0]];
    
    OCMExpect([self.mockTableView deleteRowsAtIndexPaths:deleteIndexPahts withRowAnimation:UITableViewRowAnimationFade]);
    OCMExpect([self.mockTableView endUpdates]);
    
    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2"), RACTuplePack(@"C", @"3")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"C", @"3")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_insert_all_rows_with_right_animation_if_new_data_is_inserting_in_middle
{
    OCMExpect([self.mockTableView beginUpdates]);
    
    NSArray *insertIndexPaths = @[[NSIndexPath indexPathForItem:1 inSection:0]];
    
    OCMExpect([self.mockTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight]);
    OCMExpect([self.mockTableView endUpdates]);

    
    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"C", @"3"), RACTuplePack(@"B", @"2")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_insert_all_rows_at_end_with_right_animation_if_new_data_is_adding_to_end
{
    OCMExpect([self.mockTableView beginUpdates]);
    
    NSArray *insertIndexPaths = @[[NSIndexPath indexPathForItem:2 inSection:0]];
    
    OCMExpect([self.mockTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight]);
    OCMExpect([self.mockTableView endUpdates]);
    
    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"1")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"1"), RACTuplePack(@"C", @"3")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_removes_all_rows_at_start_with_fade_animation_if_new_data_is_only_trimming_of_start
{
    OCMExpect([self.mockTableView beginUpdates]);
    
    NSArray *deleteIndexPaths = @[[NSIndexPath indexPathForItem:0 inSection:0]];
    
    OCMExpect([self.mockTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade]);
    OCMExpect([self.mockTableView endUpdates]);
    
    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"B", @"2")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_removes_all_rows_at_end_with_fade_animation_if_new_data_is_only_trimming_of_end
{
    OCMExpect([self.mockTableView beginUpdates]);
    
    NSArray *deleteIndexPaths = @[[NSIndexPath indexPathForItem:1 inSection:0]];
    
    OCMExpect([self.mockTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade]);
    OCMExpect([self.mockTableView endUpdates]);
    
    NSArray *lastData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1"), RACTuplePack(@"B", @"2")]];
    NSArray *newData = [self viewModelsFromCacheIDs:@[RACTuplePack(@"A", @"1")]];
    
    [self.animator animateWithTableView:self.mockTableView
                           sectionIndex:0
                               lastData:lastData
                                newData:newData];
    
    OCMVerifyAll(self.mockTableView);
}

@end
