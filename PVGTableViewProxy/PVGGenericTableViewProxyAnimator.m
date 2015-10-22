//
//  PVGTableViewProxyAnimator.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 13/11/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "PVGGenericTableViewProxyAnimator.h"

#import "PVGTableViewCell.h"
#import "PVGTableViewCellViewModel.h"

#define DDLogDebug NSLog

NSString *debugIDFromCellViewModel(id<PVGTableViewCellViewModel> viewModel)
{
    return [NSString stringWithFormat:@"%@:%@", [viewModel uniqueID], [viewModel cacheID]];
}

@implementation PVGGenericTableViewProxyAnimator

- (NSSet *)uniqueIDsFromViewModels:(NSArray *)viewModels
{
    NSMutableSet *uniqueIDs = [NSMutableSet set];
    for (id<PVGTableViewCellViewModel> cellViewModel in viewModels)
    {
        [uniqueIDs addObject:cellViewModel.uniqueID];
    }
    return uniqueIDs;
}

- (NSArray *)animateWithTableView:(UITableView *)tableView
                     sectionIndex:(NSInteger)sectionIndex
                         lastData:(NSArray *)lastData
                          newData:(NSArray *)newData
{
    if ([lastData count] == 0)
    {
        DDLogDebug(@"Reloading whole section because last data as empty");
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                 withRowAnimation:UITableViewRowAnimationNone];
        return @[];
    }
    else if ([newData count] == 0)
    {
        DDLogDebug(@"Reloading whole section because new data is empty");
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                 withRowAnimation:UITableViewRowAnimationFade];
        return @[];
    }
    else
    {
        NSMutableArray *indexPathsToReloadWithNoAnimation = [NSMutableArray array];
        NSMutableArray *indexPathsToDelete = [NSMutableArray array];
        NSMutableArray *indexPathsToInsert = [NSMutableArray array];
        
        NSSet *lastDataUniqueIDs = [self uniqueIDsFromViewModels:lastData];
        NSSet *newDataUniqueIDs = [self uniqueIDsFromViewModels:newData];
        
        NSMutableArray *lastDataStillHere = [NSMutableArray array];
        NSMutableArray *lastDataStillHereIndices = [NSMutableArray array];
        
        for (NSInteger i = 0; i != [lastData count]; i++)
        {
            id<PVGTableViewCellViewModel> viewModel = lastData[i];
            BOOL inLastData = YES;
            BOOL inNewData = [newDataUniqueIDs containsObject:viewModel.uniqueID];
            
            if (inLastData == YES && inNewData == NO)
            {
                // view model does not exist in new data -> Delete
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
                [indexPathsToDelete addObject:indexPath];
            }
            else if (inLastData == YES && inNewData == YES)
            {
                [lastDataStillHere addObject:viewModel];
                [lastDataStillHereIndices addObject:@(i)];
            }
        }
        
        NSMutableArray *newDataStillHere = [NSMutableArray array];
        NSMutableArray *newDataStillHereIndices = [NSMutableArray array];
        
        for (NSInteger i = 0; i != [newData count]; i++)
        {
            id<PVGTableViewCellViewModel> viewModel = newData[i];
            BOOL inLastData = [lastDataUniqueIDs containsObject:viewModel.uniqueID];
            BOOL inNewData = YES;
            
            if (inLastData == NO && inNewData == YES)
            {
                // New view model did not exist in last data -> Insert
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
                [indexPathsToInsert addObject:indexPath];
            }
            else if (inLastData == YES && inNewData == YES)
            {
                [newDataStillHere addObject:viewModel];
                [newDataStillHereIndices addObject:@(i)];
            }
        }
        
        // lastDataStillHere and newDataStillHere contain the same view models
        // but possibly in a different order. We walk through them to detect the first shuffle.
        // If we detect a shuffle we assume that the rest has changed that much that we just
        // delete the old items and add them again at the new spot.
        
        BOOL detectedShuffle = NO;
        for (NSInteger i = 0; i != [lastDataStillHere count]; i++)
        {
            id<PVGTableViewCellViewModel> lastViewModel = lastDataStillHere[i];
            id<PVGTableViewCellViewModel> newViewModel = newDataStillHere[i];
            
            if (detectedShuffle == NO && [lastViewModel.uniqueID isEqualToString:newViewModel.uniqueID])
            {
                NSNumber *lastViewModelIndex = lastDataStillHereIndices[i];
                
                BOOL forceUpdate = NO;
                
                if ([newViewModel respondsToSelector:@selector(forceUpdate)])
                {
                    forceUpdate = [newViewModel forceUpdate];
                }
                
                if ([lastViewModel.cacheID isEqualToString:newViewModel.cacheID] == NO || forceUpdate)
                {
                    // The view model has changed visually but didn't move to a new slot.
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[lastViewModelIndex integerValue]
                                                                inSection:sectionIndex];
                    [indexPathsToReloadWithNoAnimation addObject:indexPath];
                }
            }
            else
            {
                detectedShuffle = YES;
                NSNumber *lastViewModelIndex = lastDataStillHereIndices[i];
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[lastViewModelIndex integerValue]
                                                                inSection:sectionIndex];
                [indexPathsToDelete addObject:lastIndexPath];
                
                NSNumber *newViewModelIndex = newDataStillHereIndices[i];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[newViewModelIndex integerValue]
                                                               inSection:sectionIndex];
                [indexPathsToInsert addObject:newIndexPath];
            }
        }
        
#if ENABLE_TABLE_VIEW_PROXY_DEBUG
        NSMutableArray *newIds = [NSMutableArray array];
        NSMutableSet *newIdsSet = [NSMutableSet set];
        for (id<PVGTableViewCellViewModel> viewModel in newData)
        {
            NSString *debugID = debugIDFromCellViewModel(viewModel);
            [newIds addObject:debugID];
            [newIdsSet addObject:debugID];
        }
        
        
        if ([newIdsSet count] != [newData count])
        {
            // There are fewer ids in the data set than there are objects -> we have duplicates!
            NSMutableArray *lastIds = [NSMutableArray array];
            for (id<PVGTableViewCellViewModel> viewModel in lastData)
            {
                [lastIds addObject:debugIDFromCellViewModel(viewModel)];
            }
            
            DDLogDebug(@"Last data: %@", lastIds);
            DDLogDebug(@"New data: %@", newIds);
            
            NSAssert(NO, @"Duplicate ids when updating table view proxy %@", newIds);
        }
#endif
        
        
        BOOL hasRowsThatNeedAnimation = [indexPathsToDelete count] > 0 || [indexPathsToInsert count] > 0;
        if (hasRowsThatNeedAnimation || [indexPathsToReloadWithNoAnimation count] > 0)
        {
            [tableView beginUpdates];
            
            if ([indexPathsToDelete count] > 0)
            {
                DDLogDebug(@"Deleting: %@", [self idsFromIndexPaths:indexPathsToDelete referenceData:lastData]);
                [tableView deleteRowsAtIndexPaths:indexPathsToDelete
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
            
            if ([indexPathsToInsert count] > 0)
            {
                DDLogDebug(@"Inserting: %@", [self idsFromIndexPaths:indexPathsToInsert referenceData:newData]);
                [tableView insertRowsAtIndexPaths:indexPathsToInsert
                                 withRowAnimation:UITableViewRowAnimationRight];
            }
            
            [tableView endUpdates];
        }
        
        if ([indexPathsToReloadWithNoAnimation count] > 0)
        {
            DDLogDebug(@"Reloading with no animation: %@", [self idsFromIndexPaths:indexPathsToReloadWithNoAnimation referenceData:lastData]);
        }
        return indexPathsToReloadWithNoAnimation;
    }
}

- (NSArray *)idsFromIndexPaths:(NSArray *)indices referenceData:(NSArray *)referenceData
{
#if ENABLE_TABLE_VIEW_PROXY_DEBUG
    return [[indices.rac_sequence map:^id(NSIndexPath *index) {
        NSString *debugId = debugIDFromCellViewModel([referenceData objectAtIndex:index.row]);
        return [NSString stringWithFormat:@"%@ -> %@", index, debugId];
    }] array];
#else
    return indices;
#endif
}

@end