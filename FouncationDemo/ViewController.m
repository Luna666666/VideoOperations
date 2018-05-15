//
//  ViewController.m
//  FouncationDemo
//
//  Created by swkj on 16/11/18.
//  Copyright © 2016年 dnq. All rights reserved.
//

#import "ViewController.h"
#import "DNQ.pch"
#import "LsyNetworkManager.h"
#import "LsyUrlJudgment.h"
#import "UserTableViewCell.h"
#import "MainUserInfo.h"
#import "LoginViewController.h"
#import "VideoUploaderMainViewController.h"
@interface ViewController ()<UIActionSheetDelegate>{
//     MBProgressHUD * HUD;
}
@property(nonatomic,strong)UITableView *userRankTable;
@property(nonatomic,strong) NSMutableArray *array_userRankResult;
@property(nonatomic,assign)NSInteger page;
@property(nonatomic,strong)UIButton   *showHomePageBtn;
@property(nonatomic,strong)UIButton   *logoutBtn;
@property(nonatomic,strong)UIActionSheet *actionSheet;


@end
static const CGFloat MJDuration = 0.1;
@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:18],NSFontAttributeName,nil]];
}

-(UIActionSheet*)actionSheet{
    if (_actionSheet==nil) {
        _actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出当前账号?" otherButtonTitles:nil, nil];
    }
    return _actionSheet;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.actionSheet removeFromSuperview];
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"融云聊天";
    self.view.backgroundColor=[UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1.00];
    //登陆成功进入主页面按钮
    UIButton *showHomePageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    showHomePageBtn.frame=CGRectMake(10*ScreenWidth/320,74*ScreenHeight/480,ScreenWidth-2*10*ScreenWidth/320,60*ScreenHeight/480);
    showHomePageBtn.clipsToBounds=YES;
    showHomePageBtn.layer.cornerRadius=15*ScreenHeight/480;
    self.showHomePageBtn=showHomePageBtn;
    [showHomePageBtn addTarget:self action:@selector(takePhotoes) forControlEvents:UIControlEventTouchUpInside];
    showHomePageBtn.backgroundColor=[UIColor orangeColor];
    [showHomePageBtn setTitle:@"进入拍摄视频传" forState:UIControlStateNormal];
    [showHomePageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    showHomePageBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    [self.view addSubview:showHomePageBtn];
    
    //退出登录
    UIButton *logoutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame=CGRectMake(10*ScreenWidth/320,CGRectGetMaxY(showHomePageBtn.frame)+20*ScreenHeight/480,ScreenWidth-2*10*ScreenWidth/320,60*ScreenHeight/480);
    self.logoutBtn=logoutBtn;
    logoutBtn.clipsToBounds=YES;
    logoutBtn.tag=1;
    [logoutBtn addTarget:self action:@selector(logoutBtn:) forControlEvents:UIControlEventAllEvents];
    logoutBtn.layer.cornerRadius=16*ScreenHeight/480;
    logoutBtn.backgroundColor=[UIColor orangeColor];
    [logoutBtn setTitle:@"查看你上传的视频" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    [self.view addSubview:logoutBtn];
    
    
}
#pragma mark-视频拍摄上传
-(void)takePhotoes{
    VideoUploaderMainViewController *takePhotoes=[[VideoUploaderMainViewController alloc]init];
    [self presentViewController:takePhotoes animated:NO completion:nil];
    
}
#pragma mark-用户排行数据请求
-(void)refreshUserRank{
    NSString *url = [NSString stringWithFormat:@"%@/ranking/getuserranking?pageIndex=%@",BaseURL,@(self.page)];
    [[LsyNetworkManager manager].setRequest(url).RequestType(GET).HTTPHeader([APPInfo shareInfo].HTTPHeader).Parameters(nil).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON).FormData(nil) startRequestWithSuccess:^(id response) {
        
        NSLog(@"response:%@",response);
        NSString *codeStr=[response objectForKey:@"code"];
        NSLog(@"codeStr:%@",codeStr);
        if ([codeStr integerValue]==200) {
            NSLog(@"欢迎进入排行界面!");
        }
    } failure:^(NSError *error) {
        [LsyUrlJudgment initWithRespon:error];
        
    }];
}
-(void)logoutBtn:(UIButton*)sender{
    NSLog(@"查看你上传的视频");
   
//    self.actionSheet.tag = [sender tag];
//    [self.actionSheet showInView:self.view];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 1) {
        
        if (0 == buttonIndex) {
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            
            [user removeObjectForKey:@"account"];
            [user removeObjectForKey:@"password"];
            
            [user synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                LoginViewController *loginVC = [[LoginViewController alloc]init];
                [self dismissViewControllerAnimated:YES completion:nil];
                self.view.window.rootViewController = loginVC;
                
                
            });
            
        }
        
        
    }
    
}

@end
