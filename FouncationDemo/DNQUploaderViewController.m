//
//  DNQUploaderViewController.m
//  ManufacturingAlliance
//
//  Created by swkj on 16/11/29.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "DNQUploaderViewController.h"
#import "MainUserInfo.h"
#import "NSString+WZXSSLTool.h"
#import "LDProgressView.h"
#import <QiniuSDK.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import <MBProgressHUD.h>
#import "SVProgressHUD.h"
@interface DNQUploaderViewController (){
    NSString * _qiNiuToken;
    BOOL _cancelUpLoad;
    LDProgressView * _LsyProgressView;
    UIView * _showProgressView;
    NSDictionary * _uploadVideoDic;
    NSDictionary * _uploadImageDic;
    MBProgressHUD * HUD;
    BOOL isShow[7], isEdit;


}
//  -------  封面图片
@property (nonatomic, strong) UIImage *videoCoverImage;
@end

@implementation DNQUploaderViewController
- (void)viewWillDisappear:(BOOL)animated {
    if (!isEdit) {
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    //    NSLog(@"视频地址%@",self.uploadModel.videoUrl);
    [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/UploadFile/GenerateToken",HeaderURL]).HTTPHeader([APPInfo shareInfo].HTTPHeader).RequestType(GET).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON) startRequestWithSuccess:^(id response) {
        
        _qiNiuToken = response[@"result"];
        
    } failure:^(NSError *error) {
        NSLog(@"七牛token获取失败%@",error.localizedDescription);
        [LsyUrlJudgment initWithRespon:error];
    }];
    
    if (!isEdit) {
        self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"上传视频";
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(submitFeedBack:)];
     isEdit = YES;
    //设置上传封面
    [self getVideoImage];
    
    
    
}
//获取视频封面
- (void)getVideoImage {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_videoUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 600);
    CGImageRef image = [generator copyCGImageAtTime:thumbTime actualTime:nil error:nil];
    self.videoCoverImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
   
    
    
}

#pragma mark - btnClick
-(void)submitFeedBack:(UIBarButtonItem*)sender{
    if ([sender isEqual:self.navigationItem.rightBarButtonItem]) {
        
        [self.view endEditing:YES];
        //进度条
        [self createLsyProgressVC];
        //取消上传
        [self addTapThing];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HHmmss"];
        NSString * dateString = [formater stringFromDate:[NSDate date]];
        NSString *uploadID = [NSString stringWithFormat:@"%@%@",dateString,[APPInfo shareInfo].cuId];
        NSString * aId = [uploadID do32MD5];
        
        //视频上传字典
        _uploadVideoDic = @{
                            @"x:UId" :[NSString stringWithFormat:@"%@", [APPInfo shareInfo].uId],//登录获取
                            @"x:CUId":[APPInfo shareInfo].cuId,//登录获取
                            @"x:Type":@"2",
                            @"x:Introduction":@"咸鱼视频上传",
                            @"x:Title":@"李安",
                            @"x:ClassOneId":[NSString stringWithFormat:@"%ld",(long)1],
                            @"x:ClassTwoId":[NSString stringWithFormat:@"%ld",(long)2],
                            @"x:Director":@"李安",
                            @"x:Screenwriter":@"李安",
                            @"x:Performer":@"李安",
                            @"x:Price":@"20",
                            @"x:Level1":@"1",
                            @"x:SpreadCount1":@"20",
                            @"x:ReturnPercent1":@"20",
                            @"x:Level2":@"2",
                            @"x:SpreadCount2":@"20",
                            @"x:ReturnPercent2":@"20",
                            @"x:Level3":@"3",
                            @"x:SpreadCount3":@"20",
                            @"x:ReturnPercent3":@"20",
                            @"x:ExtendCycle":[NSString stringWithFormat:@"%d",4],
                            @"x:AId":aId,
                            };
        //封面上传
        _uploadImageDic = @{
                            @"x:UId" :[NSString stringWithFormat:@"%@", [APPInfo shareInfo].uId],//登录获取
                            @"x:CUId":[APPInfo shareInfo].cuId,//登录获取
                            @"x:Type":@"1",
                            @"x:Introduction":@"李安",
                            @"x:Title":@"李安",
                            @"x:ClassOneId":[NSString stringWithFormat:@"%ld",(long)1],
                            @"x:ClassTwoId":[NSString stringWithFormat:@"%ld",(long)2],
                            @"x:Director":@"李安",
                            @"x:Screenwriter":@"李安",
                            @"x:Performer":@"李安",
                            @"x:Price":@"100",
                            @"x:Level1":@"1",
                            @"x:SpreadCount1":@"20",
                            @"x:ReturnPercent1":@"20",
                            @"x:Level2":@"2",
                            @"x:SpreadCount2":@"20",
                            @"x:ReturnPercent2":@"20",
                            @"x:Level3":@"3",
                            @"x:SpreadCount3":@"20",
                            @"x:ReturnPercent3":@"20",
                            @"x:ExtendCycle":[NSString stringWithFormat:@"%d",20],
                            @"x:AId":aId,};

        //普通上传
          [self createMediaUpLoad];
        
        
    }
}

#pragma mark ----------------后来添加-----------------
//普通上传
-(void)createMediaUpLoad{
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSLog(@"视频地址%@",self.videoUrl);
    NSData * videoData = [NSData dataWithContentsOfURL:self.videoUrl];
    //图片压缩
    NSData * imageData= UIImageJPEGRepresentation(self.videoCoverImage, 0.1);
    
    
    //进度
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            HUD.progress = percent/1.25;
            _LsyProgressView.progress = percent/1.25;
            
        });
        //视频上传，是否取消，上传的时候传入字典
    } params:_uploadVideoDic checkCrc:NO cancellationSignal:^BOOL{
        return _cancelUpLoad;
    }];
    //视频封面上传
    [upManager putData:videoData key:nil token:_qiNiuToken
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  //                  NSLog(@"info的内容：%@", info);
                  NSLog(@"resp内容：%@", resp);
                  
                  if (!info.error) {
                      
                      //进度
                      QNUploadOption *opt1 = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              //                              HUD.progress = percent/5+0.8;
                              _LsyProgressView.progress = percent/5+0.8;
                          });
                      } params:_uploadImageDic checkCrc:NO cancellationSignal:nil];
                      [upManager putData:imageData key:nil token:_qiNiuToken
                                complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                    //                                       NSLog(@"info第二的内容：%@", info);
                                    //                                       NSLog(@"resp第二内容：%@", resp);
                                    if (!info.error) {
                                        
                                        HUD.hidden = YES;
                                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                        [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                                        [SVProgressHUD dismissWithDelay:3];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                        
                                       
                                    
                                    }else{
                                        HUD.hidden = YES;
                                        _cancelUpLoad = NO;
                                        NSLog(@"图片上传失败");
                                        _showProgressView.hidden = YES;
                                        
                                    }
                                } option:opt1];
                      
                      
                      
                  }else{
                      HUD.hidden = YES;
                      NSLog(@"视频上传失败");
                      _showProgressView.hidden = YES;
                      [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                      if (_cancelUpLoad) {
                          [SVProgressHUD showErrorWithStatus:@"取消上传"];
                          
                      }else{
                          [SVProgressHUD showErrorWithStatus:@"上传失败"];
                      }
                      _cancelUpLoad = NO;
                      [SVProgressHUD dismissWithDelay:2];
                  }
                  
              } option:opt];
    
}


//双击手势
-(void)addTapThing{
    UITapGestureRecognizer * doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom)];
    doubleRecognizer.numberOfTapsRequired = 2; // 双击
    [self.view addGestureRecognizer:doubleRecognizer];
}

-(void)handleDoubleTapFrom{
    _cancelUpLoad = YES;
}
-(void)createLsyProgressVC{
    _showProgressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _showProgressView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    [self.view addSubview:_showProgressView];
    _showProgressView.hidden = NO;
    
    _LsyProgressView = [[LDProgressView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/6, SCREEN_HEIGHT/3*2, self.view.frame.size.width/3*2, 14)];
    _LsyProgressView.color = [UIColor orangeColor];
    _LsyProgressView.flat = @YES;
    //    _LsyProgressView.progress = 0.40;
    _LsyProgressView.animate = @YES;
    _LsyProgressView.showStroke = @NO;
    _LsyProgressView.progressInset = @4;
    _LsyProgressView.showBackground = @NO;
    _LsyProgressView.outerStrokeWidth = @2;
    _LsyProgressView.type = LDProgressSolid;
    [_showProgressView addSubview:_LsyProgressView];
    
    UIImageView * faceIamge = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"笑脸"]];
    faceIamge.frame = CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/3, self.view.frame.size.width/3, self.view.frame.size.width/3);
    [_showProgressView addSubview:faceIamge];
    UILabel * cancelLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/2+15, self.view.frame.size.width/3, self.view.frame.size.width/6)];
    cancelLabel.textColor = [UIColor orangeColor];
    cancelLabel.textAlignment = NSTextAlignmentCenter;
    cancelLabel.font = [UIFont boldSystemFontOfSize:20];
    cancelLabel.text = @"双击取消上传";
    [_showProgressView addSubview:cancelLabel];
}



@end
