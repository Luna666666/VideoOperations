//
//  AppDelegate.m
//  FouncationDemo
//
//  Created by swkj on 16/11/18.
//  Copyright © 2016年 dnq. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "LoginViewController.h"
#import "LsyNetworkManager.h"
#import "LsyUrlJudgment.h"
#import "DNQ.pch"
#import "NSString+WZXSSLTool.h"
#import "MICSecurity.h"
#import "MainUserInfo.h"
#import "LsyVideoSdk.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [LsyVideoSdk startupWithKey:@"hc4VVhLm87hs0MWntehajK0tnZcaTLjD0VbGWGh5Rbg6CM7+ER+gy2P8MIdx/EkVmwo4ZHNwaOJW2QVdzvhh4w==" error:nil];

    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    NSString* account = [user objectForKey:@"account"];
    NSString * pwd = [user objectForKey:@"password"];
    
    if (account&&pwd) {
        [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/application/IOS",BaseURL])startRequestWithSuccess:^(id response) {
            NSString * usermobile = account;
            NSString * passWord = [pwd do32MD5];
            //            NSLog(@"账户%@,密码%@",account,pwd);
            NSDictionary * dic = @{
                                   @"usermobile":usermobile,
                                   @"pwd":passWord,
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
                    [user setObject:account forKey:@"account"];
                    //将密码写入NSUserDefaults
                    [user setObject:pwd forKey:@"password"];
                    [user synchronize];
                    NSLog(@"现在请求头的token为：%@",token);
                    
                    NSLog(@"登录成功");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        HUD.hidden = YES;
                        NSLog(@"看看名字%@",[APPInfo shareInfo].perName);
                        NSLog(@"进步登录完成的界面");
                        self.window.rootViewController = [ViewController new];
                        
                    });
                    
                    
                }else{
                    
                    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:[LoginViewController new]];
                    nav.navigationBarHidden = NO;
                    self.window.rootViewController = nav;
                   
                    
                    
                }
            } failure:^(NSError * error){
                NSLog(@"登录错误：%@",error.debugDescription);
                if ([LsyUrlJudgment initWithRespon:error]) {
                    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:[LoginViewController new]];
                    nav.navigationBar.hidden = NO;
                   
                    
                    
                }
                
                NSLog(@"登录获取去token失败");
            }];
           
            
        } failure:^(NSError *error) {
            NSLog(@"获取application错误：%@",error.debugDescription);
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:[LoginViewController new]];
            nav.navigationBarHidden = NO;
            self.window.rootViewController = nav;
           
            
        }];
    }else{
        
        
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:[LoginViewController new]];
        nav.navigationBarHidden = NO;
        self.window.rootViewController = nav;
       
        
        
        
    }
    

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
