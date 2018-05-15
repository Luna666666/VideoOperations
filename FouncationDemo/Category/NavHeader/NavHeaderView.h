//
//  NavHeaderView.h
//  ManufacturingAlliance
//
//  Created by swkj_lsy on 16/9/19.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LsyHeaderNavtionDelegate <NSObject>
@optional
- (void)popToVC:(UIView *)sender;
@end


@interface NavHeaderView : UIView
@property(nonatomic,assign)id<LsyHeaderNavtionDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title ImageName:(NSString * )imageName;
@end
