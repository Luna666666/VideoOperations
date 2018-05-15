//
//  PFNumberTableViewCell.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/23.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFNumberTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *contentField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *percent;

@property (nonatomic, copy) void (^endEditingBlock)(NSString *);

@end
