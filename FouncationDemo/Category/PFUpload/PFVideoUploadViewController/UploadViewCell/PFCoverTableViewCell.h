//
//  CoverTableViewCell.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/23.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFCoverTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, copy) void (^textChangedBlock)(NSString *);
@property (nonatomic, copy) void (^setCoverBlock)();

@end
