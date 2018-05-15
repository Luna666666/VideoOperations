//
//  NavHeaderView.m
//  ManufacturingAlliance
//
//  Created by swkj_lsy on 16/9/19.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "NavHeaderView.h"

@implementation NavHeaderView
-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title ImageName:(NSString *)imageName{
    if (self = [super initWithFrame:frame] ) {
        UILabel * label = [[UILabel alloc]init];
        label.frame = CGRectMake(80, 20, SCREEN_WIDTH-80*2, 40);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:18];
        label.text = title;
        [self addSubview:label];
        UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(15, 32, 10, 20)];
        imageview.image = [UIImage imageNamed:imageName];
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(1, 1, 40, 60);
        [btn addTarget:self action:@selector(popToVC) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self addSubview:imageview];
        
    }
    return self;
}
-(void)popToVC{
    if (self.delegate) {
        [self.delegate popToVC:self];
    }
}
@end
