//
//  UITextField+Shake.m
//  Shake
//
//  Created by lanouhn on 16/3/1.
//  Copyright © 2016年 LGQ. All rights reserved.
//

#import "UITextField+Shake.h"

/**
 * 为textField扩展一个左右晃动的动画
 */

@implementation UITextField (Shake)

- (void)shake {
    CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    keyFrame.duration = 0.3;
    CGFloat x = self.layer.position.x;
    keyFrame.values = @[@(x + 30), @(x - 30), @(x + 20), @(x - 20), @(x + 10), @(x - 10), @(x + 5), @(x - 5)];
    [self.layer addAnimation:keyFrame forKey:@"shake"];

}

@end
