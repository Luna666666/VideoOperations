//
//  VideoUploadViewController.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/23.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFVideoUploadViewController.h"
#import "PFCoverTableViewCell.h"
#import "PFSelectTableViewCell.h"
#import "PFTextTableViewCell.h"
#import "PFNumberTableViewCell.h"
#import "PFHeaderView.h"
#import "PFCoverViewController.h"
#import "SDImageCache.h"
#import "PFDBOperation.h"
#import "PFDraftViewController.h"
#import "SVProgressHUD.h"
#import <QiniuSDK.h>
#import <MBProgressHUD.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import "LDProgressView.h"
#import "Masonry.h"
#import "LsyRmoveVideo.h"
#import "MainUserInfo.h"
#import "NSString+WZXSSLTool.h"
#define DB_PATH [NSHomeDirectory() stringByAppendingString:@"Documents/Database.db"]

@interface PFVideoUploadViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL isShow[7], isEdit;
    MBProgressHUD * HUD;
    NSString * _qiNiuToken;
    BOOL _cancelUpLoad;
    LDProgressView * _LsyProgressView;
    UIView * _showProgressView;
    NSDictionary * _uploadVideoDic;
    NSDictionary * _uploadImageDic;
    NSDictionary * _uploadVideoDic1;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UIView *noticeView;
@property (nonatomic, strong) NSMutableDictionary *headerViews;
@property (nonatomic, strong) NSMutableArray *subImages;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (nonatomic, strong) NSArray *typeArray;
@property (nonatomic, strong) NSArray *subTypeArray;

@end

@implementation PFVideoUploadViewController


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
//   [self createLsyProgressVC];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"上传视频";
    self.titleArray = [NSArray arrayWithObjects:@[@"作品名称", @"作品类型", @"作品小类", @"导演", @"编剧", @"演员"], @[@"一档推广奖励", @"二档推广奖励", @"三档推广奖励"], nil];
    self.headerViews = [NSMutableDictionary dictionary];
    if (!_uploadModel) {
        self.uploadModel = [[PFUploadModel alloc] init];
        self.uploadModel.videoUrl = _videoUrl;
        self.uploadModel.spreadCycle = 1;
        self.uploadModel.spreadCycleStr = @"一个月";
        //设置上传封面
        [self getVideoImage];
    } else {
        self.videoUrl = _uploadModel.videoUrl;
        isEdit = YES;
    }
    //获取大类type
    [self getVideoTypeList:YES];
    //获取七张缩略图
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self get7VideoImage];
    });
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchToEndEditing)];
    tap.cancelsTouchesInView = YES;
    tap.delegate = self;
    [self.tableView addGestureRecognizer:tap];

    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 58, 30)];
    [saveBtn setTitle:@"草稿箱" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [saveBtn setImage:[UIImage imageNamed:@"草稿箱"] forState:UIControlStateNormal];
    [saveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"返回"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    //监听键盘弹起来
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)getVideoTypeList:(BOOL)isFirst {
    [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/mine/getbigclasslist", HeaderURL]).RequestType(GET).HTTPHeader([APPInfo shareInfo].HTTPHeader).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON) startRequestWithSuccess:^(id response) {
        self.typeArray = [NSArray arrayWithArray:response[@"result"]];
    } failure:^(NSError *error) {
        if (!isFirst) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"获取视频分类信息失败，请稍后重试";
            [hud hide:YES afterDelay:2.0];
        }
        [LsyUrlJudgment initWithRespon:error];
    }];
    [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/mine/getsmallclasslist", HeaderURL]).RequestType(GET).HTTPHeader([APPInfo shareInfo].HTTPHeader).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON) startRequestWithSuccess:^(id response) {
        self.subTypeArray = [NSArray arrayWithArray:response[@"result"]];
    } failure:^(NSError *error) {
        [LsyUrlJudgment initWithRespon:error];
    }];
}

- (void)keyboardFrameChange:(NSNotification *)notifi {
    NSDictionary *userInfo = [notifi userInfo];
    CGRect keyboardsBounds = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardsBounds.size.height;
    self.tableViewBottomConstraint.constant = keyboardHeight;
}

- (void)keyboardHide:(NSNotification *)notifi {
        self.tableViewBottomConstraint.constant = 0;
}
//获取视频封面
- (void)getVideoImage {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_videoUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 600);
    CGImageRef image = [generator copyCGImageAtTime:thumbTime actualTime:nil error:nil];
    self.uploadModel.videoCoverImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)submit {
    [self.tableView endEditing:YES];
    NSString *warningStr = [self.uploadModel hasEmpty];//检查是否有字段为空
    if (warningStr) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = warningStr;
        [hud hide:YES afterDelay:1];
        return;
    }
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
                                      @"x:Introduction":self.uploadModel.videoDescription,
                                      @"x:Title":self.uploadModel.videoName,
                                      @"x:ClassOneId":[NSString stringWithFormat:@"%ld",(long)self.uploadModel.videoType],
                                      @"x:ClassTwoId":[NSString stringWithFormat:@"%ld",(long)self.uploadModel.videoSubType],
                                      @"x:Director":self.uploadModel.videoDirection,
                                      @"x:Screenwriter":self.uploadModel.videoWriter,
                                      @"x:Performer":self.uploadModel.videoActor,
                                      @"x:Price":self.uploadModel.videoPrice,
                                      @"x:Level1":@"1",
                                      @"x:SpreadCount1":self.uploadModel.video1SpreadTimes,
                                      @"x:ReturnPercent1":self.uploadModel.video1SpreadRewards,
                                      @"x:Level2":@"2",
                                      @"x:SpreadCount2":self.uploadModel.video2SpreadTimes,
                                      @"x:ReturnPercent2":self.uploadModel.video2SpreadRewards,
                                      @"x:Level3":@"3",
                                      @"x:SpreadCount3":self.uploadModel.video3SpreadTimes,
                                      @"x:ReturnPercent3":self.uploadModel.video3SpreadRewards,
                                      @"x:ExtendCycle":[NSString stringWithFormat:@"%ld",(long)self.uploadModel.spreadCycle],
                                      @"x:AId":aId,
                                 };
    //封面上传
    _uploadImageDic = @{
                                      @"x:UId" :[NSString stringWithFormat:@"%@", [APPInfo shareInfo].uId],//登录获取
                                      @"x:CUId":[APPInfo shareInfo].cuId,//登录获取
                                      @"x:Type":@"1",
                                      @"x:Introduction":self.uploadModel.videoDescription,
                                      @"x:Title":self.uploadModel.videoName,
                                      @"x:ClassOneId":[NSString stringWithFormat:@"%ld",(long)self.uploadModel.videoType],
                                      @"x:ClassTwoId":[NSString stringWithFormat:@"%ld",(long)self.uploadModel.videoSubType],
                                      @"x:Director":self.uploadModel.videoDirection,
                                      @"x:Screenwriter":self.uploadModel.videoWriter,
                                      @"x:Performer":self.uploadModel.videoActor,
                                      @"x:Price":self.uploadModel.videoPrice,
                                      @"x:Level1":@"1",
                                      @"x:SpreadCount1":self.uploadModel.video1SpreadTimes,
                                      @"x:ReturnPercent1":self.uploadModel.video1SpreadRewards,
                                      @"x:Level2":@"2",
                                      @"x:SpreadCount2":self.uploadModel.video2SpreadTimes,
                                      @"x:ReturnPercent2":self.uploadModel.video2SpreadRewards,
                                      @"x:Level3":@"3",
                                      @"x:SpreadCount3":self.uploadModel.video3SpreadTimes,
                                      @"x:ReturnPercent3":self.uploadModel.video3SpreadRewards,
                                      @"x:ExtendCycle":[NSString stringWithFormat:@"%ld",(long)self.uploadModel.spreadCycle],
                                      @"x:AId":aId,
                                      };
//    NSDictionary * uploadImageDic1 = @{
//                                       
//                                       @"x:UId" :@"4",//登录获取
//                                       @"x:CUId":@"290037c5-1a29-4f2e-8f71-d2fc2b24",//登录获取
//                                       @"x:Type":@"1",
//                                       @"x:Introduction":@"sdfds",
//                                       @"x:Title":@"sdfds",
//                                       @"x:ClassOneId":self.uploadModel.videoType,
//                                      @"x:ClassTwoId":self.uploadModel.videoSubType,
//                                       @"x:ClassOneId":@"1",
//                                       @"x:ClassTwoId":@"2",
//                                       @"x:Director":@"sdfds",
//                                       @"x:Screenwriter":@"sdfds",
//                                       @"x:Performer":@"sdfds",
//                                       @"x:Price":@"sdfds",
//                                       @"x:Level1":@"1",
//                                       @"x:SpreadCount1":@"44",
//                                       @"x:ReturnPercent1":@"44",
//                                       @"x:Level2":@"2",
//                                       @"x:SpreadCount2":@"44",
//                                       @"x:ReturnPercent2":@"44",
//                                       @"x:Level3":@"3",
//                                       @"x:SpreadCount3":@"44",
//                                       @"x:ReturnPercent3":@"44",
//                                       
//                                       };

//    _uploadVideoDic1 = @{
//                                      
//                                      @"x:UId" :@"4",//登录获取
//                                      @"x:CUId":@"290037c5-1a29-4f2e-8f71-d2fc2b24",//登录获取
//                                      @"x:Type":@"2",
//                                      @"x:Introduction":@"sdfds",
//                                      @"x:Title":@"sdfds",
////                                      @"x:ClassOneId":self.uploadModel.videoType,
////                                      @"x:ClassTwoId":self.uploadModel.videoSubType,
//                                      @"x:ClassOneId":@"1",
//                                      @"x:ClassTwoId":@"2",
//                                      @"x:Director":@"sdfds",
//                                      @"x:Screenwriter":@"sdfds",
//                                      @"x:Performer":@"sdfds",
//                                      @"x:Price":@"sdfds",
//                                      @"x:Level1":@"1",
//                                      @"x:SpreadCount1":@"44",
//                                      @"x:ReturnPercent1":@"44",
//                                      @"x:Level2":@"2",
//                                      @"x:SpreadCount2":@"44",
//                                      @"x:ReturnPercent2":@"44",
//                                      @"x:Level3":@"3",
//                                      @"x:SpreadCount3":@"44",
//                                      @"x:ReturnPercent3":@"44",
//                                      
//                                      };
    //高强上传
    if (self.HigeQuality) {
        [self createHighUpLoad];
        //普通上传
    }else{
        [self createMediaUpLoad];
    }
}
//保存到草稿箱
- (void)save {
    [self.tableView endEditing:YES];
//    if (self.HigeQuality) {
//        
//        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//        [SVProgressHUD showErrorWithStatus:@"高清视频不支持保存草稿箱"];
//        [SVProgressHUD dismissWithDelay:2];
//
//    }else{
        NSRange range = [[_uploadModel.videoUrl absoluteString] rangeOfString:@"tmp"];
        NSString *realUrlStr = [[_uploadModel.videoUrl absoluteString] substringFromIndex:range.location];
        [[SDImageCache sharedImageCache] storeImage:_uploadModel.videoCoverImage forKey:realUrlStr];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        self.uploadModel.videoDate = [formatter stringFromDate:[NSDate date]];
        NSLog(@"保存日期%@",self.uploadModel.videoDate);
        
        PFDBOperation *operation = [PFDBOperation sharedInstance];
        if (isEdit) {
            [operation deleteUploadInfo:_uploadModel];
            if (self.didEditBlock) {
                self.didEditBlock(_uploadModel);
            }
        }
        [operation addNewUploadInfo:_uploadModel];
        
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD showSuccessWithStatus:@"已保存至草稿箱"];
        [SVProgressHUD dismissWithDelay:2];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 + NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (isEdit) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            if (!self.HigeQuality) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lsy_dealloc" object:@"dealloc"];
            }
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
        });
//    }
}
- (void)back {
    if (!self.choseMedial && !isEdit) {
        //高清上传的时候返回
         [LsyRmoveVideo LsyRmoveVideo:self.videoUrl];
    }
   
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchToEndEditing {
    [self.tableView endEditing:YES];
}

- (void)get7VideoImage {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_videoUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime videoTime = asset.duration;
    CGFloat videoSeconds = CMTimeGetSeconds(videoTime);
    
    self.subImages = [NSMutableArray array];
    NSMutableArray *times = [NSMutableArray array];
    for (NSInteger i = 0; i < 7; i ++) {
        NSValue *value = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(videoSeconds * i / 7, 600)];
        [times addObject:value];
    }
    
    __weak typeof(self) weak_self = self;
    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (image) {
            UIImage *subImage = [UIImage imageWithCGImage:image];
            [weak_self.subImages addObject:subImage];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"内存已经爆炸");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - tap gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view.superview class]) isEqualToString:@"PFSelectTableViewCell"]) {
        return NO;
    }
    return YES;
}

#pragma mark - table view dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 6;
        case 2:
            return 1;
        case 3:
            return 1;
        case 4:
        case 5:
        case 6:
            return isShow[section] ? 2 : 0;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 320;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 3) {
        return 44;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section < 2) {
        return 10;
    }
    if (section == 2) {
        NSString *noticeStr = @"若作品的默认在线观看价格为￥1.00，默认推广周期为1个月。推广视频按推广周期结算，推广周期截止清零重新计算。";
        CGFloat height = [noticeStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 56, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11], NSFontAttributeName, nil] context:nil].size.height + 8;
        return height;
    }
    if (section == 6) {
        return 80;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        if (!self.noticeView) {
            self.noticeView = [[UIView alloc] init];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 13, 13)];
            [imageView setImage:[UIImage imageNamed:@"提示"]];
            [self.noticeView addSubview:imageView];
            
            NSString *noticeStr = @"若作品的默认在线观看价格为￥1.00，默认推广周期为1个月。推广视频按推广周期结算，推广周期截止清零重新计算。";
            CGFloat height = [noticeStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 56, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11], NSFontAttributeName, nil] context:nil].size.height;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(28, 4, SCREEN_WIDTH - 56, height)];
            label.font = [UIFont systemFontOfSize:11];
            label.numberOfLines = 0;
            label.alpha = 0.7;
            label.text = noticeStr;
            [self.noticeView addSubview:label];
        }
        return _noticeView;
    }
    if (section == 6) {
        UIView *view = [[UIView alloc] init];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 150, 21, 300, 39)];
        [btn setBackgroundImage:[UIImage imageNamed:@"提交按钮"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        return view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section > 3) {
        NSString *viewKey = [NSString stringWithFormat:@"%ld", section];
        PFHeaderView *view = _headerViews[viewKey];
        if (!view) {
            view = [[PFHeaderView alloc] init];
            [self.headerViews setObject:view forKey:viewKey];
        }
        view.titleLabel.text = _titleArray[1][section - 4];
        __weak typeof(view) weak_view = view;
        __block BOOL *isShow_b = isShow;
        __weak typeof(tableView) weak_tableView = tableView;
        view.tappedBlock = ^(){
            isShow_b[section] = !isShow_b[section];
            weak_view.bottomLineView.hidden = isShow_b[section];
            [weak_view.imageView setImage: isShow_b[section] ? [UIImage imageNamed:@"向上"] : [UIImage imageNamed:@"向下"]];
            [weak_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        return view;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            PFCoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cover" forIndexPath:indexPath];
            [cell.bgImageView setImage:_uploadModel.videoCoverImage];
            [cell.coverImageView setImage:_uploadModel.videoCoverImage];
            //textView block回调
            if (_uploadModel.videoDescription.length > 0) {
                cell.textView.text = _uploadModel.videoDescription;
                cell.placeholderLabel.hidden = YES;
                cell.countLabel.text = [NSString stringWithFormat:@"%ld", MAX(0, 120 - _uploadModel.videoDescription.length)];
            }
            __weak typeof(self) weak_self = self;
            __weak typeof(cell) weak_cell = cell;
            //封面设置
            cell.setCoverBlock = ^(){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *library = [UIAlertAction actionWithTitle:@"视频截取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    PFCoverViewController *vc = [[PFCoverViewController alloc] init];
                    vc.didSelectCoverBlock = ^(UIImage *image){
                        [weak_cell.bgImageView setImage:image];
                        [weak_cell.coverImageView setImage:image];
                        weak_self.uploadModel.videoCoverImage = image;
                    };
                    if (!isEdit) {
                        vc.offset = 1;
                    }
                    vc.videoUrl = weak_self.videoUrl;
                    vc.subImages = weak_self.subImages;
                    [weak_self.navigationController pushViewController:vc animated:YES];
                }];
                UIAlertAction *video = [UIAlertAction actionWithTitle:@"本地上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    imagePicker.allowsEditing = YES;
                    imagePicker.delegate = weak_self;
                    [weak_self presentViewController:imagePicker animated:YES completion:nil];
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:library];
                [alert addAction:video];
                [alert addAction:cancel];
                [weak_self.navigationController presentViewController:alert animated:YES completion:nil];
            };
            cell.textChangedBlock = ^(NSString *text){
                weak_self.uploadModel.videoDescription = text;
            };
            return cell;
        }
        case 1:
        {
            //选择类型
            if (indexPath.row == 1 || indexPath.row == 2) {
                PFSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"select" forIndexPath:indexPath];
                cell.nameLabel.text = _titleArray[0][indexPath.row];
                NSString *content = indexPath.row == 1 ? _uploadModel.videoTypeStr : _uploadModel.videoSubTypeStr;
                if (content.length > 0) {
                    cell.contentLabel.text = content;
                    cell.contentLabel.textColor = [UIColor blackColor];
                    cell.contentLabel.alpha = 1;
                } else {
                    cell.contentLabel.text = @"请选择";
                    cell.contentLabel.textColor = [UIColor lightGrayColor];
                    cell.contentLabel.alpha = 0.8;
                }
                return cell;
            }
            PFTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
            cell.nameLabel.text = _titleArray[0][indexPath.row];
            cell.contentField.keyboardType = UIKeyboardTypeDefault;
            cell.contentField.placeholder = @"请填写";
            cell.isPrice = NO;
            __weak typeof(self) weak_self = self;
            switch (indexPath.row) {
                case 0:
                {
                    //视频名称回调
                    cell.contentField.text = _uploadModel.videoName;
                    cell.endEditingBlock = ^(NSString *text){
                        weak_self.uploadModel.videoName = text;
                    };
                }
                    break;
                case 3:
                {
                    cell.contentField.text = _uploadModel.videoDirection;
                    cell.endEditingBlock = ^(NSString *text){
                        weak_self.uploadModel.videoDirection = text;
                    };
                }
                    break;
                case 4:
                {
                    cell.contentField.text = _uploadModel.videoWriter;
                    cell.endEditingBlock = ^(NSString *text){
                        weak_self.uploadModel.videoWriter = text;
                    };
                }
                    break;
                case 5:
                {
                    //演员文字填写回调
                    cell.contentField.text = _uploadModel.videoActor;
                    cell.endEditingBlock = ^(NSString *text){
                        weak_self.uploadModel.videoActor = text;
                    };
                }
                    break;
                default:
                    break;
            }
            return cell;
        }
        case 2:
        {
            PFTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
            cell.nameLabel.text = @"作品在线观看价格";
            cell.contentField.placeholder = @"￥0.00";
            cell.contentField.keyboardType = UIKeyboardTypeDecimalPad;
            cell.isPrice = YES;
            __weak typeof(self) weak_self = self;
            //价格填写回调
            cell.endEditingBlock = ^(NSString *text){
                if (text.length > 0) {
                    weak_self.uploadModel.videoPrice = [text substringFromIndex:1];
                } else {
                    weak_self.uploadModel.videoPrice = text;
                }
            };
            if (_uploadModel.videoPrice.length > 0) {
                cell.contentField.text = [NSString stringWithFormat:@"￥%@", _uploadModel.videoPrice];
            } else {
                cell.contentField.text = @"";
            }
            return cell;
        }
        case 3:
        {
            PFSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"select" forIndexPath:indexPath];
            cell.nameLabel.text = @"推广周期";
            NSString *content = _uploadModel.spreadCycleStr;
            if (content.length > 0) {
                cell.contentLabel.text = content;
                cell.contentLabel.textColor = [UIColor blackColor];
                cell.contentLabel.alpha = 1;
            } else {
                cell.contentLabel.text = @"请选择";
                cell.contentLabel.textColor = [UIColor lightGrayColor];
                cell.contentLabel.alpha = 0.8;
            }
            return cell;
        }
        case 4:
        case 5:
        case 6:
        {
            PFNumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"number" forIndexPath:indexPath];
            __weak typeof(self) weak_self = self;
            if (indexPath.row == 0) {
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"播放次数 大于填写播放次数"];
                [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(5, 8)];
                [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(5, 8)];
                [cell.nameLabel setAttributedText:attrStr];
                cell.contentRightConstraint.constant = 10;
                cell.percent.hidden = YES;
                cell.contentField.keyboardType = UIKeyboardTypeNumberPad;
                switch (indexPath.section) {
                    case 4:
                    {
                        cell.contentField.text = _uploadModel.video1SpreadTimes;
                        //推广次数回调
                        cell.endEditingBlock = ^(NSString *text){
                            weak_self.uploadModel.video1SpreadTimes = text;
                        };
                    }
                        break;
                    case 5:
                    {
                        cell.contentField.text = _uploadModel.video2SpreadTimes;
                        cell.endEditingBlock = ^(NSString *text){
                            weak_self.uploadModel.video2SpreadTimes = text;
                        };
                    }
                        break;
                    case 6:
                    {
                        cell.contentField.text = _uploadModel.video3SpreadTimes;
                        cell.endEditingBlock = ^(NSString *text){
                            weak_self.uploadModel.video3SpreadTimes = text;
                        };
                    }
                        break;
                    default:
                        break;
                }
            } else {
                cell.nameLabel.text = @"奖励播放收益";
                cell.contentRightConstraint.constant = 24;
                cell.percent.hidden = NO;
                cell.contentField.keyboardType = UIKeyboardTypeDecimalPad;
                switch (indexPath.section) {
                    case 4:
                    {
                        cell.contentField.text = _uploadModel.video1SpreadRewards;
                        cell.endEditingBlock = ^(NSString *text){
                            weak_self.uploadModel.video1SpreadRewards = text;
                        };
                    }
                        break;
                    case 5:
                    {
                        cell.contentField.text = _uploadModel.video2SpreadRewards;
                        cell.endEditingBlock = ^(NSString *text){
                            weak_self.uploadModel.video2SpreadRewards = text;
                        };
                    }
                        break;
                    case 6:
                    {
                        cell.contentField.text = _uploadModel.video3SpreadRewards;
                        cell.endEditingBlock = ^(NSString *text){
                            weak_self.uploadModel.video3SpreadRewards = text;
                        };
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            return cell;
        }
        default:
            return nil;
    }
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 3) {
        NSString *title = @"推广周期";
        NSArray *subTitles = @[@"一个月", @"二个月", @"三个月"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak typeof(self) weak_self = self;
        for (NSInteger i = 0; i < subTitles.count; i ++) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:subTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                weak_self.uploadModel.spreadCycle = i + 1;
                weak_self.uploadModel.spreadCycleStr = subTitles[i];
                [weak_self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
            [alert addAction:action];
        }
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *title = indexPath.row == 1 ? @"作品类型" : @"作品小类";
    NSArray *subTitles = indexPath.row == 1 ? _typeArray : _subTypeArray;
    
    if (subTitles.count == 0) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.userInteractionEnabled = YES;
        [self getVideoTypeList:NO];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weak_self = self;
    for (NSInteger i = 0; i < subTitles.count; i ++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:subTitles[i][@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (indexPath.row == 1) {
                weak_self.uploadModel.videoType = [subTitles[i][@"id"] integerValue];
                weak_self.uploadModel.videoTypeStr = subTitles[i][@"name"];
            } else {
                weak_self.uploadModel.videoSubType = [subTitles[i][@"id"] integerValue];
                weak_self.uploadModel.videoSubTypeStr = subTitles[i][@"name"];
            }
            [weak_self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        [alert addAction:action];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - imagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.uploadModel.videoCoverImage = image;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ----------------后来添加-----------------
//普通上传
-(void)createMediaUpLoad{
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSLog(@"视频地址%@",self.uploadModel.videoUrl);
    NSData * videoData = [NSData dataWithContentsOfURL:self.videoUrl];
    NSData * imageData= UIImageJPEGRepresentation(self.uploadModel.videoCoverImage, 0.1);

    
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
                             
                                        if (self.choseMedial&&!isEdit) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"Lsy_dealloc" object:@"dealloc"];
                                        }
                                        //  上传成功之后调用下面的代码，删除草稿箱数据
                                        if (isEdit && self.didUploadBlock) {
                                            self.didUploadBlock();
                                            [self.navigationController popViewControllerAnimated:YES];
                                        } else {
                                            NSFileManager *manager = [NSFileManager defaultManager];
                                            NSRange range = [[_videoUrl absoluteString] rangeOfString:@"tmp"];
                                            NSString *realUrlStr = [[_videoUrl absoluteString] substringFromIndex:range.location];
                                            NSString *urlStr = [NSHomeDirectory() stringByAppendingFormat:@"/%@", realUrlStr];
                                            if ([manager fileExistsAtPath:urlStr]) {
                                                [manager removeItemAtPath:urlStr error:nil];
                                            }
                                        }
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
//高清上传
-(void)createHighUpLoad{
    //七牛上传
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSLog(@"视频地址%@",self.uploadModel.videoUrl);
//    NSData * videoData = [NSData dataWithContentsOfURL:self.videoUrl];
    //封面
    NSData * imageData= UIImageJPEGRepresentation(self.uploadModel.videoCoverImage, 0.1);
    
    //进度
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            HUD.progress = percent/1.25;
            _LsyProgressView.progress = percent/1.25;
            
        });
        //字典：_uploadVideoDic
    } params:_uploadVideoDic checkCrc:NO cancellationSignal:^BOOL{
        return _cancelUpLoad;
    }];
    //封面，七牛token 推流，上传视频到七牛
    [upManager putPHAsset:self.videoAsset key:nil token:_qiNiuToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"怎么回事%@",resp);
        if (!info.error) {
            
            //进度
            QNUploadOption *opt1 = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    HUD.progress = percent/5+0.8;
                    _LsyProgressView.progress = percent/5+0.8;
                });
                //封面字典
            } params:_uploadImageDic checkCrc:NO cancellationSignal:nil];
            [upManager putData:imageData key:nil token:_qiNiuToken
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//                                                              NSLog(@"info第二的内容：%@", info);
//                                                              NSLog(@"resp第二内容：%@", resp);
                          if (!info.error) {
                              
                              HUD.hidden = YES;
                              _showProgressView.hidden = YES;
                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                              [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                              [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                              [SVProgressHUD dismissWithDelay:3];
                              
                              
                              
                         }else{
                              HUD.hidden = YES;
                              _cancelUpLoad = NO;
                               _showProgressView.hidden = YES;
                              NSLog(@"图片上传失败");
                              
                          }
                      } option:opt1];
            
        }else{
            HUD.hidden = YES;
            _showProgressView.hidden = YES;
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            if (_cancelUpLoad) {
                [SVProgressHUD showErrorWithStatus:@"取消上传"];
               
            }else{
                [SVProgressHUD showErrorWithStatus:@"上传失败"];
            }
              _cancelUpLoad = NO;
            [SVProgressHUD dismissWithDelay:2];

            NSLog(@"视频上传失败");
        }
        
        
    } option:opt];

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
//双击手势
-(void)addTapThing{
    UITapGestureRecognizer * doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom)];
    doubleRecognizer.numberOfTapsRequired = 2; // 双击
    [self.view addGestureRecognizer:doubleRecognizer];
}

-(void)handleDoubleTapFrom{
    HUD.hidden = YES;
    _cancelUpLoad = YES;
}
@end
