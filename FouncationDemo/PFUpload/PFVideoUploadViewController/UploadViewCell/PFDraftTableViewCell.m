//
//  PFDraftTableViewCell.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/30.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFDraftTableViewCell.h"

@implementation PFDraftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.coverImageView.layer.cornerRadius = 3;
    self.coverImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)edit:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cell:clickedEditButton:)]) {
        [self.delegate cell:self clickedEditButton:sender];
    }
}

- (IBAction)upload:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cell:clickedUploadButton:)]) {
        [self.delegate cell:self clickedUploadButton:sender];
    }
}

@end
