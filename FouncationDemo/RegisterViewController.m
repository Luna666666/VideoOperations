//
//  RegisterViewController.m
//  FouncationDemo
//
//  Created by swkj on 16/11/19.
//  Copyright © 2016年 dnq. All rights reserved.
//

#import "RegisterViewController.h"
#import "UITextField+Shake.h"
#import "MobileNum.h"
#import "LsyUrlJudgment.h"
#import "LsyNetworkManager.h"
#import "DNQ.pch"
#import "MICSecurity.h"
#import "MainUserInfo.h"
#import "NSString+WZXSSLTool.h"
#import "DNQ.pch"
#import "ViewController.h"
@interface RegisterViewController ()<UITextFieldDelegate>{
    int _i;
    NSTimer *_timer;
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

@implementation RegisterViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _i=30;
    self.title=@"注册";
    [self addSubViews];
}
-(void)addSubViews{
    self.bodyView=[[UIView alloc]initWithFrame:CGRectMake(0,30*ScreenHeight/480,ScreenWidth,152*ScreenHeight/480)];
    self.bodyView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.bodyView];
    
    UILabel *accountLabel=[UILabel new];
    accountLabel.frame=CGRectMake(10*ScreenWidth/320,10*ScreenHeight/480,60*ScreenWidth/320,30*ScreenHeight/480);
    accountLabel.textColor=[UIColor blackColor];
    accountLabel.text=@"账号";
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
    
    UILabel *passwordLabel=[UILabel new];
    passwordLabel.frame=CGRectMake(10*ScreenWidth/320,firstLine.frame.origin.y+firstLine.frame.size.height+10,60*ScreenWidth/320,30*ScreenHeight/480);
    passwordLabel.textColor=[UIColor blackColor];
    passwordLabel.text=@"密码";
    passwordLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.bodyView addSubview:passwordLabel];
    
    self.passwordTF=[[UITextField alloc]initWithFrame:CGRectMake(passwordLabel.frame.origin.x+passwordLabel.frame.size.width,passwordLabel.frame.origin.y,ScreenWidth-passwordLabel.frame.origin.x-passwordLabel.frame.size.width,passwordLabel.frame.size.height)];
    self.passwordTF.backgroundColor=[UIColor whiteColor];
    self.passwordTF.returnKeyType=UIReturnKeyDone;
    self.passwordTF.textAlignment=NSTextAlignmentLeft;
    self.passwordTF.placeholder=@"请输入密码";
    self.passwordTF.delegate=self;
    self.passwordTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.passwordTF.borderStyle= UITextBorderStyleNone;
    [self.bodyView addSubview:self.passwordTF];
    
    UIView *secondLine=[UIView new];
    secondLine.frame=CGRectMake(passwordLabel.frame.origin.x,passwordLabel.frame.origin.y+passwordLabel.frame.size.height+10,ScreenWidth-(2*10)*ScreenWidth/320,1*ScreenHeight/480);
    secondLine.backgroundColor=[UIColor colorWithRed:0.886 green:0.886 blue:0.886 alpha:1.00];
    [self.bodyView addSubview:secondLine];
    
    UILabel *veryLabel=[UILabel new];
    veryLabel.frame=CGRectMake(10*ScreenWidth/320,secondLine.frame.origin.y+secondLine.frame.size.height+10*ScreenHeight/480,60*ScreenWidth/320,30*ScreenHeight/480);
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
    
    
    self.verifyTF=[[UITextField alloc]initWithFrame:CGRectMake(passwordLabel.frame.origin.x+passwordLabel.frame.size.width,veryLabel.frame.origin.y,115*ScreenWidth/320,veryLabel.frame.size.height)];
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
    [nextBtn setTitle:@"注册" forState:UIControlStateNormal];
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
    NSLog(@"下一步按钮被点击");
    if(![MobileNum isMobile:self.accountTF.text]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的手机号" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if (self.passwordTF.text.length < 6 ||self.passwordTF.text.length >16) {
        [self.passwordTF shake];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入长度为6-16的密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (!self.verifyTF.text.length){
        [self.verifyTF shake];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入验证码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Lsy_countDown" object:@"Yes_Down"];
    //存入密码和账户
    [APPInfo shareInfo].account = self.accountTF.text;
    [APPInfo shareInfo].password =self.passwordTF.text;
    [APPInfo Save];
    //菊花
//    HUD = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:HUD];
//    //如果设置此属性则当前的view置于后台
//    HUD.dimBackground = YES;
//    //设置对话框文字
//    HUD.labelText = @"注册中";
//    [HUD show:YES];
    
    //请求头
    NSString * base = @"swkj";
    NSString * key = @"1111";
    NSString * newKey = [NSString stringWithFormat:@"%@%@",base,key];
    //    NSLog(@"新的钥匙：%@",newKey);
    NSString * iv = @"1111";
    NSString * newIv = [NSString stringWithFormat:@"%@%@",base,iv];
    //    NSLog(@"新的IV：%@",newIv);
    NSString * des = [MICSecurity encryptWithDES:[NSString stringWithFormat:@"%@/Account/Register",BaseURL] Key:newKey Iv:newIv];
    NSString * application = @"IOS";
    NSString * Authorization = [NSString stringWithFormat:@"%@:%@",application,des];
    NSString * base64 = [Authorization doBase64];
    NSString * HttpHeader = [NSString stringWithFormat:@"Basic %@",base64];
    NSMutableDictionary * HTTPHeader = [NSMutableDictionary dictionary];
    [HTTPHeader setObject:HttpHeader forKey:@"Authorization"];
    NSDictionary * registerDic = @{
                                   @"userMobile":self.accountTF.text,
                                   @"userPwd":[self.passwordTF.text do32MD5],
                                   @"verifiCode":self.verifyTF.text,
                                   @"personTypeID":@"1"
                                   };
    NSLog(@"字典%@",registerDic);
    UIImage * image = [UIImage imageNamed:@"个性签名"];
    LsyNetworkFormData * formData = [LsyNetworkFormData formDataWithImg:image
                                                                   name:@"img" fileName:@"image.png" scale:1];
    
    [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/Account/Register",BaseURL]).RequestType(POST).HTTPHeader(HTTPHeader).Parameters(registerDic).FormData(formData) startRequestWithSuccess:^(id response) {
        if ([response[@"code"] intValue] == 200) {
            //保存信息
            NSDictionary * resultDic = response[@"result"];
            NSDictionary * personDic = resultDic[@"person"];
            [APPInfo shareInfo].uId = personDic[@"uId"];
            [APPInfo shareInfo].perType = personDic[@"personType"];
            [APPInfo shareInfo].cuId = personDic[@"cuId"];
            [APPInfo shareInfo].perName  = personDic[@"perName"];
            [APPInfo shareInfo].perImg = personDic[@"perImg"];
            [APPInfo shareInfo].realName = personDic[@"realName"];
            [APPInfo shareInfo].userNumName = personDic[@"userName"];
            NSDictionary * tokenDic = resultDic[@"token"];
            NSDictionary * header = @{
                                      @"Authorization":[NSString stringWithFormat:@"%@ %@",tokenDic[@"token_type"],tokenDic[@"access_token"]]
                                      
                                      };
            [APPInfo shareInfo].HTTPHeader = header;
            [APPInfo Save];
            
            //将token写入NSUserDefaults
            NSDictionary * tokenDict = resultDic[@"token"];
            NSString * token = [NSString stringWithFormat:@"%@ %@",tokenDict[@"token_type"],tokenDict[@"access_token"]];
            NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
            NSDictionary * Authorization = @{
                                             @"Authorization":token
                                             };
            [user setObject:Authorization forKey:@"token"];
            //将账户写入NSUserDefaults
            [user setObject:self.accountTF.text forKey:@"account"];
            //将密码写入NSUserDefault
            [user setObject:self.passwordTF.text forKey:@"password"];
            [user synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                HUD.hidden = YES;
                [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                //注册成功后进入主页面
                self.view.window.rootViewController = [ViewController new];
                [self.view endEditing:YES];
                NSLog(@"个人注册成功啦");
            });
            
            
            
        }else if ([response[@"code"] intValue]== 201){
            dispatch_async(dispatch_get_main_queue(), ^{
//                HUD.hidden = YES;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已存在该用户" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            });
            
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //个人注册失败
//                HUD.hidden = YES;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:response[@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                
                
            });
        }
        
        
        
    } failure:^(NSError *error) {
//        HUD.hidden = YES;
        NSLog(@"个人注册外部错误%@",error.localizedDescription);
        [LsyUrlJudgment initWithRespon:error];
    }];

    
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
        //    NSLog(@"新的钥匙：%@",newKey);
        NSString * iv = @"1111";
        NSString * newIv = [NSString stringWithFormat:@"%@%@",base,iv];
        //    NSLog(@"新的IV：%@",newIv);
        NSString * des = [MICSecurity encryptWithDES:[NSString stringWithFormat:@"%@/Account/GetValidateCodeByReg",BaseURL] Key:newKey Iv:newIv];
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
        
        [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/Account/GetValidateCodeByReg",BaseURL]).RequestType(POST).HTTPHeader(HTTPHeader).Parameters(numDic).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON).FormData(nil) startRequestWithSuccess:^(id response) {
            //                NSLog(@"信息：%@",response);
            if ([response[@"code"] integerValue] == 200) {
                NSLog(@"message:%@",response[@"msg"]);
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
           self.getVeryCodeBtn.userInteractionEnabled = YES;
            NSLog(@"获取验证码错误%@",error.localizedDescription);
            [LsyUrlJudgment initWithRespon:error];
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
