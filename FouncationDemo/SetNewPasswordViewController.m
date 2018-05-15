//
//  SetNewPasswordViewController.m
//  FouncationDemo
//
//  Created by swkj on 16/11/23.
//  Copyright © 2016年 dnq. All rights reserved.
//

#import "SetNewPasswordViewController.h"
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
#import <MBProgressHUD.h>
@interface SetNewPasswordViewController ()<UITextFieldDelegate>{
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

@implementation SetNewPasswordViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
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
    accountLabel.text=@"新密码";
    accountLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.bodyView addSubview:accountLabel];
    
    self.accountTF=[[UITextField alloc]initWithFrame:CGRectMake(accountLabel.frame.origin.x+accountLabel.frame.size.width,accountLabel.frame.origin.y,ScreenWidth-accountLabel.frame.origin.x-accountLabel.frame.size.width,accountLabel.frame.size.height)];
    self.accountTF.backgroundColor=[UIColor whiteColor];
    self.accountTF.returnKeyType=UIReturnKeyDone;
    self.accountTF.textAlignment=NSTextAlignmentLeft;
    self.accountTF.placeholder=@"请输入新密码";
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
    passwordLabel.text=@"再次确认";
    passwordLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.bodyView addSubview:passwordLabel];
    
    self.passwordTF=[[UITextField alloc]initWithFrame:CGRectMake(passwordLabel.frame.origin.x+passwordLabel.frame.size.width,passwordLabel.frame.origin.y,ScreenWidth-passwordLabel.frame.origin.x-passwordLabel.frame.size.width,passwordLabel.frame.size.height)];
    self.passwordTF.backgroundColor=[UIColor whiteColor];
    self.passwordTF.returnKeyType=UIReturnKeyDone;
    self.passwordTF.textAlignment=NSTextAlignmentLeft;
    self.passwordTF.placeholder=@"请再次输入新密码";
    self.passwordTF.delegate=self;
    self.passwordTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.passwordTF.borderStyle= UITextBorderStyleNone;
    [self.bodyView addSubview:self.passwordTF];
    
    //下一步按钮
    UIButton *nextBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame=CGRectMake(10*ScreenWidth/320,self.bodyView.frame.origin.y+self.bodyView.frame.size.height+40*ScreenHeight/480,ScreenWidth-2*10*ScreenWidth/320,39*ScreenHeight/480);
    self.nextBtn=nextBtn;
    [nextBtn setTitle:@"登录" forState:UIControlStateNormal];
    nextBtn.backgroundColor=[UIColor orangeColor];
    nextBtn.clipsToBounds=YES;
    nextBtn.layer.cornerRadius=15*ScreenHeight/480;
    [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    [self.view addSubview:nextBtn];

    
    
    
    
    }
//登录点击
-(void)nextBtnClicked{
    if ([self.accountTF.text isEqualToString:@""]||[self.passwordTF.text isEqualToString:@""]) {
        [self.accountTF shake];
        [self.passwordTF shake];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入长度为6-16的密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if ([self.accountTF.text isEqualToString:self.passwordTF.text ]) {
        
        if (self.accountTF.text.length < 6 || self.accountTF.text.length >16){
            [self.accountTF shake];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入长度为6-16的密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else{
            
            //登录
            //菊花
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            //如果设置此属性则当前的view置于后台
            HUD.dimBackground = YES;
            //设置对话框文字
            HUD.labelText = @"修改中....";
            [HUD show:YES];
            
            //请求头
            NSString * base = @"swkj";
            NSString * key = @"1111";
            NSString * newKey = [NSString stringWithFormat:@"%@%@",base,key];
            //    NSLog(@"新的钥匙：%@",newKey);
            NSString * iv = @"1111";
            NSString * newIv = [NSString stringWithFormat:@"%@%@",base,iv];
            //    NSLog(@"新的IV：%@",newIv);
            NSString * des = [MICSecurity encryptWithDES:[NSString stringWithFormat:@"%@/Account/UpdatePwd",BaseURL] Key:newKey Iv:newIv];
            NSString * application = @"IOS";
            NSString * Authorization = [NSString stringWithFormat:@"%@:%@",application,des];
            //        NSLog(@"新的Authorization：%@",Authorization);
            NSString * base64 = [Authorization doBase64];
            NSString * HttpHeader = [NSString stringWithFormat:@"Basic %@",base64];
            NSMutableDictionary * HTTPHeader = [NSMutableDictionary dictionary];
            [HTTPHeader setObject:HttpHeader forKey:@"Authorization"];
            
            NSDictionary * checkNumDic = @{
                                           @"userMobile":self.num,
                                           @"userPwd":[self.accountTF.text do32MD5],
                                           @"verifiCode":self.checkNum,
                                           };
            [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/Account/UpdatePwd",BaseURL]).RequestType(PUT).HTTPHeader(HTTPHeader).Parameters(checkNumDic).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON).FormData(nil) startRequestWithSuccess:^(id response) {
                NSLog(@"看看多少是空的%@",response);
                if ([response[@"code"] intValue] == 200) {
                    [APPInfo releaseInfo];
                    //保存信息
                    NSDictionary * resultDic = response[@"result"];
                    NSDictionary * personDic = resultDic[@"person"];
                    [APPInfo shareInfo].uId = [NSString stringWithFormat:@"%@", personDic[@"uId"]];
                    [APPInfo shareInfo].perType = personDic[@"personType"];
                    [APPInfo shareInfo].cuId = personDic[@"cuId"];
                    NSLog(@"看看那个怎么回事%@",personDic[@"cuId"]);
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
                    [user setObject:self.num forKey:@"account"];
                    //将密码写入NSUserDefault
                    [user setObject:self.accountTF.text forKey:@"password"];
                    [user synchronize];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HUD.hidden = YES;
                        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                        self.view.window.rootViewController = [ViewController new];
                        NSLog(@"修改成功");
                        
                    });
                    
                    
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HUD.hidden = YES;
                        
                    });
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:response[@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
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
        
    }else if (self.accountTF.text.length < 6 || self.accountTF.text.length >16){
        [self.accountTF shake];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入长度为6-16的密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else{
        [self.passwordTF shake];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您输入的密码不相同" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
