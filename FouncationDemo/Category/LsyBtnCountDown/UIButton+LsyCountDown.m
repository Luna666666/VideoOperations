//
//  UIButton+LsyCountDown.m
//  LsyCountDown
//
//  Created by swkj_lsy on 16/7/28.
//  Copyright © 2016年 swkj_lsy. All rights reserved.
//

#import "UIButton+LsyCountDown.h"
#import <objc/runtime.h>
@interface UIButton()
@property(nonatomic,strong)id lsy_canDoValue;
@property(nonatomic,strong)id lsy_sender;
@property(nonatomic,copy)NSString * lsy_memberName;
@property(nonatomic,assign)BOOL lsy_canDo;
@property(nonatomic,copy)BOOL(^lsy_judge_block)();
@property(nonatomic,assign)NSString * lsy_getCanDown;
@end

@implementation UIButton (LsyCountDown)
static NSString * lsy_oldText;
static NSUInteger lsy_CountDown_time;
static NSString * lsy_CountDown_title = @"秒后可重新发送";
static NSString * lsy_canDoValue_key = @"lsy_canDoValue";
static NSString * lsy_sender_key = @"lsy_sender";
static NSString * lsy_memberName_key = @"lsy_memberName";
static NSString * lsy_canDo_key = @"lsy_canDo";
static NSString * lsy_judgeBlock_key = @"lsy_judgeBlock";
static NSString * lsy_getCanDown = @"lsy_getCanDown";

#pragma mark -- runtime
-(void)setLsy_canDoValue:(id)lsy_canDoValue{
    objc_setAssociatedObject(self, &lsy_canDoValue_key, lsy_canDoValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id)lsy_canDoValue{
    return objc_getAssociatedObject(self, &lsy_canDoValue_key);
}
-(void)setLsy_sender:(id)lsy_sender{
    objc_setAssociatedObject(self, &lsy_sender_key, lsy_sender, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id)lsy_sender{
    return objc_getAssociatedObject(self, &lsy_sender_key);
}
-(void)setLsy_memberName:(NSString *)lsy_memberName{
    objc_setAssociatedObject(self, &lsy_memberName_key, lsy_memberName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSString *)lsy_memberName{
    return objc_getAssociatedObject(self, &lsy_memberName_key);
}
-(void)setLsy_canDo:(BOOL)lsy_canDo{
    objc_setAssociatedObject(self, &lsy_canDo_key, @(lsy_canDo), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)lsy_canDo{
    return [objc_getAssociatedObject(self, &lsy_canDo_key) boolValue];
}
-(void)setLsy_getCanDown:(NSString *)lsy_getCanDown{
    objc_setAssociatedObject(self, &lsy_getCanDown, lsy_getCanDown, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL)lsy_getCanDown{
    return objc_getAssociatedObject(self, &lsy_getCanDown);
}
-(void)setLsy_judge_block:(BOOL (^)())lsy_judge_block{
    objc_setAssociatedObject(self, &lsy_judgeBlock_key, lsy_judge_block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL(^)())lsy_judge_block{
    return objc_getAssociatedObject(self, &lsy_judgeBlock_key);
}
-(void)Lsy_CountDown:(NSUInteger)time Title:(NSString *)title{
    lsy_CountDown_title = title;
    [self Lsy_CountDown:time];
}
-(void)Lsy_CountDown:(NSUInteger)time{
    lsy_oldText = self.titleLabel.text;
    lsy_CountDown_time = time;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addTarget:self action:@selector(lsy_btnClick:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)lsy_btnClick:(UIButton *)sender{
    if (self.lsy_judge_block) {
        self.lsy_canDo = self.lsy_judge_block();
        if (self.lsy_canDo) {
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDown:) name:@"Lsy_countDown" object:nil];
            
        }
    }else{
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDown:) name:@"Lsy_countDown" object:nil];
    }
}

-(void)lsy_countdown{
    self.enabled = NO;
  
    [self setTitle:[NSString stringWithFormat:@"%lu%@",lsy_CountDown_time,lsy_CountDown_title] forState:UIControlStateNormal];
    static dispatch_once_t onceToken;
   
        NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(lsy_timeTitleChange:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];

    
    NSLog(@"开始倒计时%lu",lsy_CountDown_time);
    
}
-(void)getDown:(NSNotification *)notic{
    if ([[notic object] isEqualToString:@"Yes_Down"]) {
        
        [self lsy_countdown];
      
 
    }
}
-(void)lsy_timeTitleChange:(NSTimer *)timer{
    NSInteger time = [self.titleLabel.text integerValue];
    time--;
    if (time == 0 ||time > lsy_CountDown_time) {
        self.enabled = YES;
        [self setTitle:lsy_oldText forState:UIControlStateNormal];
        [timer invalidate];
        return;
    }
    self.enabled = NO;
    [self setTitle:[NSString stringWithFormat:@"%lu%@",time,lsy_CountDown_title] forState:UIControlStateNormal];
    NSLog(@"倒数计时%lu",time);
    
}
-(void)Lsy_addCondition:(id)sender member:(NSString *)memberName canDoValue:(id)canDoValue{
    self.lsy_sender = sender;
    self.lsy_memberName = memberName;
    self.lsy_canDoValue = canDoValue;
    [sender addObserver:self forKeyPath:memberName options:NSKeyValueObservingOptionNew context:nil];
}
-(void)Lsy_addjudge:(BOOL (^)())judge{
    self.lsy_judge_block = judge;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([object isEqual:self.lsy_sender]) {
        if ([keyPath isEqualToString:self.lsy_memberName]) {
            self.lsy_canDo = [change[@"new"] isEqual:self.lsy_canDoValue];
            NSLog(@"看看是什么%@",self.lsy_canDoValue);
        }
    }
}
-(void)dealloc{
    NSLog(@"销毁");
}

@end
