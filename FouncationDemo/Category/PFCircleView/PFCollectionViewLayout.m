//
//  PFCollectionViewLayout.m
//  ImageTransform
//
//  Created by Ponfey on 16/9/10.
//  Copyright © 2016年 thirdnet. All rights reserved.
//

#import "PFCollectionViewLayout.h"
#import "PFCollectionViewCell.h"

#define CollectionViewWidth self.collectionView.bounds.size.width
#define CollectionViewHeight self.collectionView.bounds.size.height

@implementation PFCollectionViewLayout

- (void)prepareLayout{
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat itemWidth = CollectionViewWidth * 0.65;
    self.itemSize = CGSizeMake(itemWidth, itemWidth * 3/4);
    self.minimumLineSpacing = -65;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *attributes = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    
    CGFloat centerX = self.collectionView.contentOffset.x + CollectionViewWidth / 2;
    for (UICollectionViewLayoutAttributes *attr in attributes) {
        CGFloat offset = attr.center.x - centerX;
        CGFloat scale = MAX(-1, MIN(1, offset / (CollectionViewWidth * 2/5)));
        
        CATransform3D trans = CATransform3DIdentity;
        trans.m34 = 1.0 / -1000;
        trans = CATransform3DRotate(trans, M_PI/3 * scale, 0, -1, 0);
        trans = CATransform3DScale(trans, 1 - 0.2 * fabs(scale), 1 - 0.2 * fabs(scale), 0);
        
        PFCollectionViewCell *cell = (PFCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:attr.indexPath];
        cell.layer.transform = trans;
    }
    
    return attributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    // 计算出最终显示的矩形框
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;

    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];

    // 计算collectionView最中心点的x值
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;

    // 存放最小的间距值
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
            minDelta = attrs.center.x - centerX;
        }
    }

    // 修改原有的偏移量
    proposedContentOffset.x += minDelta;
    return proposedContentOffset;
}

@end
