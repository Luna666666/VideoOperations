//
//  PFHeaderView.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/26.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFHeaderView : UIView

@property (nonatomic, copy) void (^tappedBlock)();
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *bottomLineView;

@end
