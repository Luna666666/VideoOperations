//
//  ForgettingViewController.m
//  FouncationDemo
//
//  Created by swkj on 16/11/23.
//  Copyright © 2016年 dnq. All rights reserved.
//

#import "ForgettingViewController.h"
#import "UITextField+Shake.h"
#import "MobileNum.h"
#import "LsyUrlJudgment.h"
#import "LsyNetworkManager.h"
#import "DNQ.pch"
#import "MICSecurity.h"
#import "MainUserInfo.h"
#import "NSString+WZXSSLTool.h"
#import "DNQ.pch"
#import <MBProgressHUD.h>
#import "SetNewPasswordViewController.h"
@interface ForgettingViewController ()<UITextFieldDelegate>{
    int _i;
    NSTimer *_timer;
    MBProgressHUD * HUD;

}
@property(nonatomic,strong)UIView *bodyView;
@property(nonatomic,strong)UIButton *check;
@property(nonatomic,strong)UITextField   *accountTF;
@property(nonatomic,strong)UITextField   *passwordTF;
@property(nonatomic,strong)UITextField   *verifyTF;
@property(nonatomic,strong)UIButton   *getVeryCodeBtn;
@property(nonatomic,strong)UIButton   *nextBtn;
@property(nonatomic,strong)UILabel *timeLabel;

@end

@implementation ForgettingViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _i=30;
    self.title=@"找回密码";
    [self addSubViews];
}
-(void)addSubViews{
    self.bodyView=[[UIView alloc]initWithFrame:CGRectMake(0,30*ScreenHeight/480,ScreenWidth,152*ScreenHeight/480)];
    self.bodyView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.bodyView];
    
    UILabel *accountLabel=[UILabel new];
    accountLabel.frame=CGRectMake(10*ScreenWidth/320,10*ScreenHeight/480,60*ScreenWidth/320,30*ScreenHeight/480);
    accountLabel.textColor=[UIColor blackColor];
    accountLabel.text=@"手机号";
    accountLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.bodyView addSubview:accountLabel];
    
    self.accountTF=[[UITextField alloc]initWithFrame:CGRectMake(accountLabel.frame.origin.x+accountLabel.frame.size.width,accountLabel.frame.origin.y,ScreenWidth-accountLabel.frame.origin.x-accountLabel.frame.size.width,accountLabel.frame.size.height)];
    self.accountTF.backgroundColor=[UIColor whiteColor];
    self.accountTF.returnKeyType=UIReturnKeyDone;
    self.accountTF.textAlignment=NSTextAlignmentLeft;
    self.accountTF.placeholder=@"请输入手机号";
    self.accountTF.delegate=self;
    self.accountTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.accountTF.borderStyle= UITextBorderStyleNone;
    [self.bodyView addSubview:self.accountTF];
    
    UIView *firstLine=[UIView new];
    firstLine.frame=CGRectMake(accountLabel.frame.origin.x,accountLabel.frame.origin.y+accountLabel.frame.size.height+10*ScreenHeight/480,ScreenWidth-(2*10)*ScreenWidth/320,1*ScreenHeight/480);
    firstLine.backgroundColor=[UIColor colorWithRed:0.886 green:0.886 blue:0.886 alpha:1.00];
    [self.bodyView addSubview:firstLine];
    
    
    UILabel *veryLabel=[UILabel new];
    veryLabel.frame=CGRectMake(10*ScreenWidth/320,firstLine.frame.origin.y+firstLine.frame.size.height+10*ScreenHeight/480,60*ScreenWidth/320,30*ScreenHeight/480);
    veryLabel.textColor=[UIColor blackColor];
    veryLabel.text=@"验证码";
    veryLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.bodyView addSubview:veryLabel];
    
    UIButton *getVeryCode=[UIButton buttonWithType:UIButtonTypeCustom];
    getVeryCode.frame=CGRectMake(ScreenWidth-122*ScreenWidth/320,veryLabel.frame.origin.y,100*ScreenWidth/320,veryLabel.frame.size.height);
    self.getVeryCodeBtn=getVeryCode;
    [getVeryCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getVeryCode setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [getVeryCode addTarget:self action:@selector(setGetVeryCodeBtn) forControlEvents:UIControlEventTouchUpInside];
    getVeryCode.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    [getVeryCode setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.bodyView addSubview:getVeryCode];
    
    //计数
    
    UILabel *timeLabel=[UILabel new];
    timeLabel.frame=CGRectMake(ScreenWidth-122*ScreenWidth/320,veryLabel.frame.origin.y,100*ScreenWidth/320,veryLabel.frame.size.height);
    timeLabel.textColor=[UIColor orangeColor];
    timeLabel.text=[NSString stringWithFormat:@"%d秒后可重新发送",_i];
    self.timeLabel=timeLabel;
    timeLabel.hidden=YES;
    timeLabel.adjustsFontSizeToFitWidth=YES;
    timeLabel.font=[UIFont boldSystemFontOfSize:17];
    [self.bodyView addSubview:timeLabel];
    
    
    
    UIView *shuLine=[UIView new];
    shuLine.frame=CGRectMake(getVeryCode.frame.origin.x-5*ScreenWidth/320,veryLabel.frame.origin.y,1*ScreenWidth/320,29*ScreenHeight/480);
    shuLine.backgroundColor=[UIColor orangeColor];
    [self.bodyView addSubview:shuLine];
    
    
    self.verifyTF=[[UITextField alloc]initWithFrame:CGRectMake(veryLabel.frame.origin.x+veryLabel.frame.size.width,veryLabel.frame.origin.y,115*ScreenWidth/320,veryLabel.frame.size.height)];
    self.verifyTF.backgroundColor=[UIColor whiteColor];
    self.verifyTF.returnKeyType=UIReturnKeyDone;
    self.verifyTF.textAlignment=NSTextAlignmentLeft;
    self.verifyTF.placeholder=@"输入验证码";
    self.verifyTF.delegate=self;
    self.verifyTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.verifyTF.borderStyle= UITextBorderStyleNone;
    [self.bodyView addSubview:self.verifyTF];
    //下一步按钮
    UIButton *nextBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame=CGRectMake(10*ScreenWidth/320,self.bodyView.frame.origin.y+self.bodyView.frame.size.height+40*ScreenHeight/480,ScreenWidth-2*10*ScreenWidth/320,39*ScreenHeight/480);
    self.nextBtn=nextBtn;
    nextBtn.backgroundColor=[UIColor orangeColor];
    nextBtn.clipsToBounds=YES;
    nextBtn.layer.cornerRadius=15*ScreenHeight/480;
    [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    [self.view addSubview:nextBtn];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
//点击下一步按钮
-(void)nextBtnClicked{
    if(![MobileNum isMobile:self.accountTF.text]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的手机号" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }else{
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText = @"校验中....";
        [HUD show:YES];
        //请求头
        NSString * base = @"swkj";
        NSString * key = @"1111";
        NSString * newKey = [NSString stringWithFormat:@"%@%@",base,key];
        //    NSLog(@"新的钥匙：%@",newKey);
        NSString * iv = @"1111";
        NSString * newIv = [NSString stringWithFormat:@"%@%@",base,iv];
        //    NSLog(@"新的IV：%@",newIv);
        NSString * des = [MICSecurity encryptWithDES:[NSString stringWithFormat:@"%@/Account/ValidateCode",BaseURL] Key:newKey Iv:newIv];
        NSString * application = @"IOS";
        NSString * Authorization = [NSString stringWithFormat:@"%@:%@",application,des];
        //        NSLog(@"新的Authorization：%@",Authorization);
        NSString * base64 = [Authorization doBase64];
        NSString * HttpHeader = [NSString stringWithFormat:@"Basic %@",base64];
        NSMutableDictionary * HTTPHeader = [NSMutableDictionary dictionary];
        [HTTPHeader setObject:HttpHeader forKey:@"Authorization"];
        
        NSDictionary * checkNumDic = @{
                                       @"mobile":self.accountTF.text,
                                       @"code":self.verifyTF.text
                                       };
        
        [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/Account/ValidateCode",BaseURL]).RequestType(POST).HTTPHeader(HTTPHeader).Parameters(checkNumDic).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON).FormData(nil) startRequestWithSuccess:^(id response) {
            if ([response[@"code"] intValue] == 200) {
                HUD.hidden=YES;
                SetNewPasswordViewController * setNewPWDVC = [[SetNewPasswordViewController alloc]init];
                setNewPWDVC.num = self.accountTF.text;
                setNewPWDVC.checkNum = self.verifyTF.text;
                [self presentViewController:setNewPWDVC animated:YES completion:nil];
                
            }else{
                HUD.hidden=YES;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证码错误" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } failure:^(NSError *error) {
            if ([LsyUrlJudgment initWithRespon:error]) {
                HUD.hidden = YES;
            }
            NSLog(@"检验验证码错误%@",error.localizedDescription);
        }];
        
    }
   
    
    
    
    
}
//验证码按钮被点击
-(void)setGetVeryCodeBtn{
    NSLog(@"获取验证码按钮被点击");
    [self.view endEditing:YES];
    self.getVeryCodeBtn.userInteractionEnabled = NO;
    if (![MobileNum isMobile:self.accountTF.text]) {
        [self.accountTF shake];
        self.getVeryCodeBtn.userInteractionEnabled = YES;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的手机号" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        
        //请求头
        NSString * base = @"swkj";
        NSString * key = @"1111";
        NSString * newKey = [NSString stringWithFormat:@"%@%@",base,key];
        
        NSString * iv = @"1111";
        NSString * newIv = [NSString stringWithFormat:@"%@%@",base,iv];
        
        NSString * des = [MICSecurity encryptWithDES:[NSString stringWithFormat:@"%@/Account/GetValidateCodeByPwd",BaseURL] Key:newKey Iv:newIv];
        NSString * application = @"IOS";
        NSString * Authorization = [NSString stringWithFormat:@"%@:%@",application,des];
        
        NSString * base64 = [Authorization doBase64];
        NSString * HttpHeader = [NSString stringWithFormat:@"Basic %@",base64];
        NSMutableDictionary * HTTPHeader = [NSMutableDictionary dictionary];
        [HTTPHeader setObject:HttpHeader forKey:@"Authorization"];
        
        NSString * num = self.accountTF.text;
        NSDictionary * numDic = @{
                                  @"mobile":num,
                                  };
        
        [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/Account/GetValidateCodeByPwd",BaseURL]).RequestType(POST).HTTPHeader(HTTPHeader).Parameters(numDic).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON).FormData(nil) startRequestWithSuccess:^(id response) {
            //            NSLog(@"信息：%@",response);
            if ([response[@"code"] integerValue] == 200&&!self.getVeryCodeBtn.selected) {
                [self showCountDown];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证码发送成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:response[@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            
        } failure:^(NSError *error) {
            [LsyUrlJudgment initWithRespon:error];
            self.getVeryCodeBtn.userInteractionEnabled = YES;
            NSLog(@"获取验证码错误%@",error.localizedDescription);
        }];
        
    }
    
    
}
-(void)showCountDown{
    _timeLabel.hidden = NO;
    self.getVeryCodeBtn.hidden = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Dnq_timeTitleChange:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate distantPast]];
}
-(void)Dnq_timeTitleChange:(NSTimer *)timer{
    _i--;
    if (_i == 0) {
        _i = 30;
        self.timeLabel.text = [NSString stringWithFormat:@"%d秒后可重新发送",_i];
        self.timeLabel.font=[UIFont systemFontOfSize:17];
        _timeLabel.hidden = YES;
        self.getVeryCodeBtn.hidden = NO;
        self.getVeryCodeBtn.userInteractionEnabled = YES;
        [_timer setFireDate:[NSDate distantFuture]];
        return;
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%d秒后可重新发送",_i];
}



@end
