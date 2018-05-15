//
//  LoginViewController.m
//  FouncationDemo
//
//  Created by swkj on 16/11/19.
//  Copyright © 2016年 dnq. All rights reserved.
//

#import "LoginViewController.h"
#import "UITextField+Shake.h"
#import "MobileNum.h"
#import "LsyUrlJudgment.h"
#import "LsyNetworkManager.h"
#import "DNQ.pch"
#import "MICSecurity.h"
#import "MainUserInfo.h"
#import "NSString+WZXSSLTool.h"
#import "ViewController.h"
#import "RegisterViewController.h"
#import "ForgettingViewController.h"
@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *HeadView;

@property (weak, nonatomic) IBOutlet UIView *MiddleView;

@property (weak, nonatomic) IBOutlet UILabel *AccountLabel;

@property (weak, nonatomic) IBOutlet UIView *Line;

@property (weak, nonatomic) IBOutlet UILabel *PassWordLabel;


@property (weak, nonatomic) IBOutlet UITextField *PasswordTF;

@property (weak, nonatomic) IBOutlet UITextField *AccountTF;


@property (weak, nonatomic) IBOutlet UIButton *LoginBtn;

@property (weak, nonatomic) IBOutlet UIButton *ForgetBtn;



@property (weak, nonatomic) IBOutlet UILabel *HaveNoAccount;


@property (weak, nonatomic) IBOutlet UIButton *RegisterBtn;



@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=YES;
    self.AccountTF.delegate=self;
    self.PasswordTF.delegate=self;
    self.view.backgroundColor=[UIColor colorWithRed:0.886 green:0.886 blue:0.886 alpha:1.00];
    self.Line.backgroundColor=[UIColor colorWithRed:0.800 green:0.796 blue:0.800 alpha:1.00];
    [self.ForgetBtn setTitleColor:[UIColor colorWithRed:0.992 green:0.510 blue:0.082 alpha:1.00] forState:UIControlStateNormal];
    self.HaveNoAccount.textColor=[UIColor colorWithRed:0.639 green:0.639 blue:0.639 alpha:1.00];
    [self.RegisterBtn setTitleColor:[UIColor colorWithRed:0.992 green:0.510 blue:0.082 alpha:1.00] forState:UIControlStateNormal];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)LoginBtn:(UIButton *)sender {
    NSLog(@"登录按钮被点击了");
    if (![MobileNum isMobile:self.AccountTF.text] ) {
        [self.AccountTF shake];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的手机号" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (self.PasswordTF.text.length < 6 || self.PasswordTF.text.length >16) {
        [self.PasswordTF shake];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入长度为6-16的密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        //开始登录
        //菊花
       
        
        NSString * usermobile = self.AccountTF.text;
        
        [self fouctionOfLoginWithNumber:usermobile AndPwd:self.PasswordTF.text];
    }

    
}
-(void)fouctionOfLoginWithNumber:(NSString *)number AndPwd:(NSString *)pwd{
    
    [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/application/IOS",BaseURL])startRequestWithSuccess:^(id response) {
        //        NSLog(@"结果：%@",response);
        NSString * base = @"swkj";
        NSString * iv = response[@"iv"];
        NSString * key = response[@"key"];
        NSString * newKey = [NSString stringWithFormat:@"%@%@",base,key];
        //    NSLog(@"新的钥匙：%@",newKey);
        
        NSString * newIv = [NSString stringWithFormat:@"%@%@",base,iv];
        //    NSLog(@"新的IV：%@",newIv);
        NSString * des = [MICSecurity encryptWithDES:[NSString stringWithFormat:@"%@/Account/Login",BaseURL] Key:newKey Iv:newIv];
        NSString * application = response[@"name"];
        NSString * Authorization = [NSString stringWithFormat:@"%@:%@",application,des];
        //    NSLog(@"新的Authorization：%@",Authorization);
        NSString * base64 = [Authorization doBase64];
        NSString * HttpHeader = [NSString stringWithFormat:@"Basic %@",base64];
        NSMutableDictionary * HTTPHeader = [NSMutableDictionary dictionary];
        [HTTPHeader setObject:HttpHeader forKey:@"Authorization"];
        NSDictionary * dic = @{
                               @"usermobile":number,
                               @"pwd":[pwd do32MD5],
                               };
        
        [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/Account/Login",BaseURL]).RequestType(POST).HTTPHeader(HTTPHeader).Parameters(dic).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON) startRequestWithSuccess:^(id response) {
            NSLog(@"登录成功信息：%@",response);
            //    NSLog(@"登录code:%@",response[@"code"]);
            if ([response[@"code"] intValue] == 200) {
                //保存信息
                NSDictionary * resultDic = response[@"result"];
                NSDictionary * personDic = resultDic[@"person"];
                [APPInfo shareInfo].uId = [NSString stringWithFormat:@"%@", personDic[@"uId"]];
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
                [user setObject:number forKey:@"account"];
                //将密码写入NSUserDefaults
                [user setObject:pwd forKey:@"password"];
                [user synchronize];
                //        NSLog(@"现在请求头的token为：%@",token);
                
                //        NSLog(@"登录成功");
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    HUD.hidden = YES;
                    //            NSLog(@"看看名字%@",[APPInfo shareInfo].perName);
                    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                    self.view.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[ViewController new]];
                    NSLog(@"进步登录完成的界面");
                    
                });
                
                
            }else{
//                HUD.hidden = YES;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:response[@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            
            
        } failure:^(NSError *error) {
//            HUD.hidden = YES;
            [LsyUrlJudgment initWithRespon:error];
            NSLog(@"登录失败错误：%@",error.description);;
        }];
        
    } failure:^(NSError *error) {
//        HUD.hidden = YES;
        [LsyUrlJudgment initWithRespon:error];
        NSLog(@"获取application错误：%@",error.description);
    }];
}


- (IBAction)ForgetBtnClicked:(UIButton *)sender {
    NSLog(@"忘记密码按钮被点击");
    ForgettingViewController *forgetPassword=[[ForgettingViewController alloc]init];
    [self presentViewController:forgetPassword animated:YES completion:nil];
    
}


- (IBAction)RegisterBtnClicked:(UIButton *)sender {
    RegisterViewController *registerVC=[[RegisterViewController alloc]init];
    [self presentViewController:registerVC animated:YES completion:nil];
    NSLog(@"注册按钮被点击了");
}
#pragma mark-UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES ;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"开始编辑");
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"结束编辑");
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
