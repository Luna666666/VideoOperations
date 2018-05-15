//
//  PFDraftTableViewCell.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/30.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFDraftTableViewCell;

@protocol PFDraftTableViewCellDelegate <NSObject>

@optional
- (void)cell:(PFDraftTableViewCell *)cell clickedEditButton:(UIButton *)btn;
- (void)cell:(PFDraftTableViewCell *)cell clickedUploadButton:(UIButton *)btn;

@end

@interface PFDraftTableViewCell : UITableViewCell

@property (nonatomic, weak) id<PFDraftTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
