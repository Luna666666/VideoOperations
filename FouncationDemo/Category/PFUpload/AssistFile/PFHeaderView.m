//
//  PFHeaderView.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/26.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFHeaderView.h"

@implementation PFHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 100, 22)];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_titleLabel];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 29, 18, 14, 8)];
        [self.imageView setImage:[UIImage imageNamed:@"向下"]];
        [self addSubview:_imageView];
        
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43.7, SCREEN_WIDTH, 0.3)];
        self.bottomLineView.backgroundColor = [UIColor lightGrayColor];
        self.bottomLineView.alpha = 0.7;
        [self addSubview:_bottomLineView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHide)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)showOrHide {
    if (self.tappedBlock) {
        self.tappedBlock();
    }
}

@end
