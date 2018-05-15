//
//  PFCollectionViewCell.m
//  ImageTransform
//
//  Created by Ponfey on 16/9/10.
//  Copyright © 2016年 thirdnet. All rights reserved.
//

#import "PFCollectionViewCell.h"

@implementation PFCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headerImageView.layer.cornerRadius = 16;
    self.headerImageView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHeaderView)];
    [self.headerImageView addGestureRecognizer:tap];
}

- (void)clickHeaderView {
    if ([self.delegate respondsToSelector:@selector(cellClickedHeaderView:)]) {
        [self.delegate cellClickedHeaderView:self];
    }
}

@end
