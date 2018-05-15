//
//  LsyUrlJudgment.m
//  NetworkManager
//
//  Created by swkj_lsy on 16/5/30.
//  Copyright © 2016年 wzx. All rights reserved.
//

#import "LsyUrlJudgment.h"
#import "LsyNetworkManager.h"
#import "MainUserInfo.h"
#import "MICSecurity.h"
#import "NSString+WZXSSLTool.h"
#import "XSInfoView.h"
#import "DNQ.pch"
@implementation LsyUrlJudgment


+(BOOL)initWithRespon:(NSError *)error{
    
    //重新登录
    if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[self alloc] init] changeAuthorization];
                    });
        return YES;
        //链接服务器失败
    }else if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"未能连接到服务器。"]){
        XSInfoViewStyle *style = [[XSInfoViewStyle alloc] init];
        style.info = @"服务器链接失败";
        style.layoutStyle = XSInfoViewLayoutStyleVertical;
        [XSInfoView showInfoWithStyle:style onView:[UIApplication sharedApplication].keyWindow];
        return YES;
        //请求超时
    }else if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"请求超时。"]||[error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"The request timed out."]){
        XSInfoViewStyle *style = [[XSInfoViewStyle alloc] init];
        style.info = @"请求超时";
        style.layoutStyle = XSInfoViewLayoutStyleVertical;
        [XSInfoView showInfoWithStyle:style onView:[UIApplication sharedApplication].keyWindow];
        return YES;
        //突然断网的情况
    }else if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"网络连接已中断。"]){
        XSInfoViewStyle *style = [[XSInfoViewStyle alloc] init];
        style.info = @"网络连接中断";
        style.layoutStyle = XSInfoViewLayoutStyleVertical;
        [XSInfoView showInfoWithStyle:style onView:[UIApplication sharedApplication].keyWindow];
        
        return YES;
        //服务器404（服务器被换了）
    }else if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]){
        XSInfoViewStyle *style = [[XSInfoViewStyle alloc] init];
        style.info = @"服务器404";
        style.layoutStyle = XSInfoViewLayoutStyleVertical;
        [XSInfoView showInfoWithStyle:style onView:[UIApplication sharedApplication].keyWindow];
        
        return YES;
    }
    else{
        return NO;
    }
}
+(BOOL)showLineFailde:(NSError *)error{
    if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"未能连接到服务器。"]) {
        XSInfoViewStyle *style = [[XSInfoViewStyle alloc] init];
        style.info = @"连接服务器失败";
        style.layoutStyle = XSInfoViewLayoutStyleVertical;
        [XSInfoView showInfoWithStyle:style onView:[UIApplication sharedApplication].keyWindow];
         
        return YES;
    
    }else{
        return NO;
    }

    
}
+(BOOL)showLineOutTime:(NSError *)error{
    return YES;
}

-(void)changeAuthorization{
    NSLog(@"开始重新登录");
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    NSString* account = [user objectForKey:@"account"];
    NSString * pwd = [user objectForKey:@"password"];
    if (account&&pwd) {
        [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/api/application/IOS",BaseURL]) startRequestWithSuccess:^(id response) {
            NSString * usermobile = account;
            NSString * passWord = [pwd do32MD5];
            
            NSDictionary * dic = @{
                                   @"usermobile":usermobile,
                                   @"pwd":passWord,
                                   @"BaiduLatitude":@"0",
                                   @"BaiduLongitude":@"0"
                                   };
            NSString * base = @"swkj";
            NSString * key = @"1111";
            NSString * newKey = [NSString stringWithFormat:@"%@%@",base,key];
            //    NSLog(@"新的钥匙：%@",newKey);
            NSString * iv = @"1111";
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
            //    NSLog(@"请求头%@",HttpHeader);
            
            
            [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/Account/Login",BaseURL]).RequestType(POST).HTTPHeader(HTTPHeader).Parameters(dic).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON).FormData(nil) startRequestWithSuccess:^(id response) {
                
                NSLog(@"登录成功后的信息%@",response[@"code"]);
                if ([response[@"code"] intValue] == 200) {
                    //保存信息
                    NSDictionary * resultDic = response[@"result"];
                    NSDictionary * personDic = resultDic[@"person"];
                    [APPInfo shareInfo].uId = personDic[@"uId"];
                    [APPInfo shareInfo].cuId = personDic[@"cuId"];
                    [APPInfo shareInfo].perType = personDic[@"personType"];
                    [APPInfo shareInfo].perName  = personDic[@"perName"];
                    [APPInfo shareInfo].perImg = personDic[@"perImg"];
                    [APPInfo shareInfo].pNo = personDic[@"pNo"];
                    [APPInfo shareInfo].perAir = personDic[@"popularity"];
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
                    [user setObject:account forKey:@"account"];
                    //将密码写入NSUserDefaults
                    [user setObject:pwd forKey:@"password"];
                    [user synchronize];
                    NSLog(@"现在请求头的token为：%@",token);
                    
                    NSLog(@"登录成功");
                    
                    
                }else{
                    
                    
                }
            } failure:^(NSError * error){
                NSLog(@"登录获取去token失败");
            }];
            
            
        } failure:^(NSError *error) {
            
        }];
    }

}
@end
