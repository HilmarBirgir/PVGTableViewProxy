//
//  PVGTableViewCellWithCollectionView.h
//  
//
//  Created by Alexander Annas Helgason on 07/07/16.
//
//

#import "PVGTableViewCell.h"

/**
 *  For UITableViewCells that have a UICollectionView embedded in, should conform to this protocol,
 *  so the behavior of the collection view in the tableview will be correct.
 *
 *  Example is that when multiple cells in the UITableView are UITableViewCells with an embedded UICollectionView,
 *  conforming to this protocol will correctly save the content offset for each of the UICollectionView cells.
 */
@protocol PVGTableViewCellWithCollectionView <PVGTableViewCell>

@property (weak, readwrite, nonatomic) UICollectionView *collectionView;

@end