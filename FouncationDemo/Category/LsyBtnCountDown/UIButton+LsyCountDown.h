//
//  UIButton+LsyCountDown.h
//  WZXCountDown
//
//  Created by swkj_lsy on 16/7/28.
//  Copyright © 2016年 WzxJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (LsyCountDown)

-(void)Lsy_CountDown:(NSUInteger)time;
-(void)Lsy_CountDown:(NSUInteger)time Title:(NSString *)title;
-(void)Lsy_addjudge:(BOOL(^)())judge;
-(void)Lsy_addCondition:(id)sender member:(NSString *)memberName canDoValue:(id)canDoValue;
-(void)getDown:(NSNotification *)notic;
@end
