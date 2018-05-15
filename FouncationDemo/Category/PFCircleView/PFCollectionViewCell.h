//
//  PFCollectionViewCell.h
//  ImageTransform
//
//  Created by Ponfey on 16/9/10.
//  Copyright © 2016年 thirdnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFCollectionViewCell;

@protocol PFCollectionViewCellDelegate <NSObject>

@optional
- (void)cellClickedHeaderView:(PFCollectionViewCell *)cell;

@end

@interface PFCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<PFCollectionViewCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *rankImageView;
@property (weak, nonatomic) IBOutlet UILabel *walletLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadPersonLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *playTimesLabel;
@property (weak, nonatomic) IBOutlet UIView *profitView;
@property (weak, nonatomic) IBOutlet UIImageView *isFreeView;
@property (weak, nonatomic) IBOutlet UIImageView *perTypeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profitViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *walletLabelWidthConstraint;

@end
