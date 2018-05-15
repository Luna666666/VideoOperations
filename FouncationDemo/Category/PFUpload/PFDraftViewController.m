//
//  PFDraftViewController.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/30.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFDraftViewController.h"
#import "PFDraftTableViewCell.h"
#import "PFDBOperation.h"
#import "PFVideoUploadViewController.h"
#import "SDImageCache.h"
#import "LDProgressView.h"
#import <QiniuSDK.h>
#import "SVProgressHUD.h"
#import "PFUploadModel.h"
#import "NSString+WZXSSLTool.h"
#import "MainUserInfo.h"
#import "PFPlayerViewController.h"

@interface PFDraftViewController ()<UITableViewDelegate, UITableViewDataSource, PFDraftTableViewCellDelegate>{
    LDProgressView * _LsyProgressView;
    UIView * _showProgressView;
    BOOL _cancelUpLoad;
    NSString * _qiNiuToken;
    NSDictionary * _uploadVideoDic;
    NSDictionary * _uploadImageDic;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sourceArray;

@end

@implementation PFDraftViewController
-(void)viewWillAppear:(BOOL)animated{
    [[LsyNetworkManager manager].setRequest([NSString stringWithFormat:@"%@/UploadFile/GenerateToken",HeaderURL]).HTTPHeader([APPInfo shareInfo].HTTPHeader).RequestType(GET).RequestSerialize(RequestSerializerHTTP).ResponseSerialize(ResponseSerializerJSON) startRequestWithSuccess:^(id response) {
        _qiNiuToken = response[@"result"];
        
    } failure:^(NSError *error) {
        NSLog(@"七牛token获取失败%@",error.localizedDescription);
    }];

    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"草稿箱";
    
    [self getDataFromDB];
   
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PFDraftTableViewCell" bundle:nil] forCellReuseIdentifier:@"draft"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearDraft)];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"返回"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
     [self createLsyProgressVC];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getDataFromDB {
    NSArray *array = [[PFDBOperation sharedInstance] queryAllUploadInfo];
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        PFUploadModel *model1 = obj1;
        PFUploadModel *model2 = obj2;
        return [[formatter dateFromString:model2.videoDate] compare:[formatter dateFromString:model1.videoDate]];
    }];
    self.sourceArray = [NSMutableArray array];
    PFUploadModel *lastModel = nil;
    NSInteger lastIdx = -1;
    for (PFUploadModel *model in sortedArray) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        NSDate *date = [formatter dateFromString:model.videoDate];
        NSDate *lastDate = [formatter dateFromString:lastModel.videoDate];
        [formatter setDateFormat:@"yyyy年MM月"];
        if ([[formatter stringFromDate:date] isEqualToString:[formatter stringFromDate:lastDate]]) {
            [self.sourceArray[lastIdx] addObject:model];
        } else {
            NSMutableArray *array = [NSMutableArray arrayWithObject:model];
            [self.sourceArray addObject:array];
            lastIdx ++;
        }
        lastModel = model;
    }
}

- (void)deleteUploadInfoOfIndexPath:(NSIndexPath *)indexPath {
    PFUploadModel *model = _sourceArray[indexPath.section][indexPath.row];
    [self.sourceArray[indexPath.section] removeObjectAtIndex:indexPath.row];
    if ([self.sourceArray[indexPath.section] count] == 0) {
        [self.sourceArray removeObjectAtIndex:indexPath.section];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [[PFDBOperation sharedInstance] deleteUploadInfo:model];
    
    NSRange range = [[model.videoUrl absoluteString] rangeOfString:@"tmp"];
    NSString *realUrlStr = [[model.videoUrl absoluteString] substringFromIndex:range.location];
    [[SDImageCache sharedImageCache] removeImageForKey:realUrlStr];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *urlStr = [NSHomeDirectory() stringByAppendingFormat:@"/%@", realUrlStr];
    if ([manager fileExistsAtPath:urlStr]) {
        [manager removeItemAtPath:urlStr error:nil];
    }
    if (self.draftDidChangeHandle) {
        self.draftDidChangeHandle();
    }
}

- (void)clearDraft {
    if (_sourceArray.count == 0) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:@"是否确定清空草稿箱?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    __weak typeof(self) weak_self = self;
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"清空" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weak_self.sourceArray removeAllObjects];
        [weak_self.tableView reloadData];
        [[PFDBOperation sharedInstance] deleteAllUploadInfo];
        for (PFUploadModel *model in weak_self.sourceArray) {
            NSRange range = [[model.videoUrl absoluteString] rangeOfString:@"tmp"];
            NSString *realUrlStr = [[model.videoUrl absoluteString] substringFromIndex:range.location];
            [[SDImageCache sharedImageCache] removeImageForKey:realUrlStr];
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *urlStr = [NSHomeDirectory() stringByAppendingFormat:@"/%@", realUrlStr];
            if ([manager fileExistsAtPath:urlStr]) {
                [manager removeItemAtPath:urlStr error:nil];
            }
        }
        if (weak_self.draftDidChangeHandle) {
            weak_self.draftDidChangeHandle();
        }
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - table view dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sourceArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    PFUploadModel *model = _sourceArray[section][0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date = [formatter dateFromString:model.videoDate];
    [formatter setDateFormat:@"yyyy年MM月"];
    return [formatter stringFromDate:date];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFDraftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"draft" forIndexPath:indexPath];
    cell.delegate = self;
    PFUploadModel *model = _sourceArray[indexPath.section][indexPath.row];
    cell.nameLabel.text = model.videoName;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date = [formatter dateFromString:model.videoDate];
    [formatter setDateFormat:@"MM-dd"];
    cell.dateLabel.text = [formatter stringFromDate:date];
    [cell.coverImageView setImage:model.videoCoverImage];
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteUploadInfoOfIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFUploadModel *model = _sourceArray[indexPath.section][indexPath.row];
    PFPlayerViewController *vc = [[PFPlayerViewController alloc] init];
    vc.videoUrl = model.videoUrl;
    vc.titleStr = model.videoName;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 编辑和上传处理方法
- (void)cell:(PFDraftTableViewCell *)cell clickedEditButton:(UIButton *)btn {
    UIStoryboard *upload = [UIStoryboard storyboardWithName:@"PFVideoUpload" bundle:nil];
    PFVideoUploadViewController *vc = [upload instantiateInitialViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    vc.uploadModel = self.sourceArray[indexPath.section][indexPath.row];
    __weak typeof(self) weak_self = self;
    vc.didUploadBlock = ^(){
        [weak_self deleteUploadInfoOfIndexPath:indexPath];
    };
    vc.didEditBlock = ^(PFUploadModel *model){
        [weak_self.sourceArray[indexPath.section] removeObjectAtIndex:indexPath.row];
        if ([weak_self.sourceArray[indexPath.section] count] == 0) {
            [weak_self.sourceArray removeObjectAtIndex:indexPath.section];
            [weak_self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [weak_self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        if (weak_self.sourceArray.count != 0) {
            PFUploadModel *latestModel = weak_self.sourceArray[0][0];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy年MM月dd日"];
            NSDate *date = [formatter dateFromString:model.videoDate];
            NSDate *latestDate = [formatter dateFromString:latestModel.videoDate];
            [formatter setDateFormat:@"yyyy年MM月"];
            if ([[formatter stringFromDate:date] isEqualToString:[formatter stringFromDate:latestDate]]) {
                [weak_self.sourceArray[0] insertObject:model atIndex:0];
                [weak_self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                NSMutableArray *array = [NSMutableArray arrayWithObject:model];
                [weak_self.sourceArray addObject:array];
                [weak_self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } else {
            NSMutableArray *array = [NSMutableArray arrayWithObject:model];
            [weak_self.sourceArray addObject:array];
            [weak_self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cell:(PFDraftTableViewCell *)cell clickedUploadButton:(UIButton *)btn {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    PFUploadModel *model = self.sourceArray[indexPath.section][indexPath.row];
    //    model  即为上传需要的数据
    //  判断是否有空
    if (![model hasEmpty]) {
        //    成功之后 调用下面的代码  删除草稿箱数据
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HHmmss"];
        NSString * dateString = [formater stringFromDate:[NSDate date]];
        NSString *uploadID = [NSString stringWithFormat:@"%@%@",dateString,[APPInfo shareInfo].cuId];
        NSString * aId = [uploadID do32MD5];
 
            _uploadVideoDic = @{
                                              @"x:UId" :[NSString stringWithFormat:@"%@", [APPInfo shareInfo].uId],//登录获取
                                              @"x:CUId":[APPInfo shareInfo].cuId,//登录获取
                                              @"x:Type":@"2",
                                              @"x:Introduction":model.videoDescription,
                                              @"x:Title":model.videoName,
                                              @"x:ClassOneId":[NSString stringWithFormat:@"%ld",(long)model.videoType],
                                              @"x:ClassTwoId":[NSString stringWithFormat:@"%ld",(long)model.videoSubType],
                                              @"x:Director":model.videoDirection,
                                              @"x:Screenwriter":model.videoWriter,
                                              @"x:Performer":model.videoActor,
                                              @"x:Price":model.videoPrice,
                                              @"x:Level1":@"1",
                                              @"x:SpreadCount1":model.video1SpreadTimes,
                                              @"x:ReturnPercent1":model.video1SpreadRewards,
                                              @"x:Level2":@"2",
                                              @"x:SpreadCount2":model.video2SpreadTimes,
                                              @"x:ReturnPercent2":model.video2SpreadRewards,
                                              @"x:Level3":@"3",
                                              @"x:SpreadCount3":model.video3SpreadTimes,
                                              @"x:ReturnPercent3":model.video3SpreadRewards,
                                              @"x:ExtendCycle":[NSString stringWithFormat:@"%ld",(long)model.spreadCycle],
                                              @"x:AId":aId,
                                         };
            _uploadImageDic = @{
                                              @"x:UId" :[NSString stringWithFormat:@"%@", [APPInfo shareInfo].uId],//登录获取
                                              @"x:CUId":[APPInfo shareInfo].cuId,//登录获取
                                              @"x:Type":@"1",
                                              @"x:Introduction":model.videoDescription,
                                              @"x:Title":model.videoName,
                                              @"x:ClassOneId":[NSString stringWithFormat:@"%ld",(long)model.videoType],
                                              @"x:ClassTwoId":[NSString stringWithFormat:@"%ld",(long)model.videoSubType],
                                              @"x:Director":model.videoDirection,
                                              @"x:Screenwriter":model.videoWriter,
                                              @"x:Performer":model.videoActor,
                                              @"x:Price":model.videoPrice,
                                              @"x:Level1":@"1",
                                              @"x:SpreadCount1":model.video1SpreadTimes,
                                              @"x:ReturnPercent1":model.video1SpreadRewards,
                                              @"x:Level2":@"2",
                                              @"x:SpreadCount2":model.video2SpreadTimes,
                                              @"x:ReturnPercent2":model.video2SpreadRewards,
                                              @"x:Level3":@"3",
                                              @"x:SpreadCount3":model.video3SpreadTimes,
                                              @"x:ReturnPercent3":model.video3SpreadRewards,
                                            @"x:ExtendCycle":[NSString stringWithFormat:@"%ld",(long)model.spreadCycle],
                                              @"x:AId":aId,
                                              };
        _showProgressView.hidden = NO;
        [self addTapThing];
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
            NSData * videoData = [NSData dataWithContentsOfURL:model.videoUrl];
            NSData * imageData= UIImageJPEGRepresentation(model.videoCoverImage, 0.1);
        //进度
        QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _LsyProgressView.progress = percent/1.25;
                
            });
            
        
        } params:_uploadVideoDic checkCrc:NO cancellationSignal:^BOOL{
            return _cancelUpLoad;
        }];
        
        [upManager putData:videoData key:nil token:_qiNiuToken
                  complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                      //                  NSLog(@"info的内容：%@", info);
                      //                  NSLog(@"resp内容：%@", resp);
                      
                      if (!info.error) {
                          
                          //进度
                          QNUploadOption *opt1 = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  _LsyProgressView.progress = percent/5+0.8;
                              });
                          } params:_uploadImageDic checkCrc:NO cancellationSignal:nil];
                          [upManager putData:imageData key:nil token:_qiNiuToken
                                    complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//                                        NSLog(@"info第二的内容：%@", info);
//                                        NSLog(@"resp第二内容：%@", resp);
                                        if (!info.error) {
                                            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                                            [SVProgressHUD dismissWithDelay:3];
                                            _showProgressView.hidden = YES;
                                            //删除
                                            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                            [self deleteUploadInfoOfIndexPath:indexPath];
                                            
                                        }else{
                                            _cancelUpLoad = NO;
                                            NSLog(@"图片上传失败");
                                            _showProgressView.hidden = YES;
                                            
                                        }
                                    } option:opt1];
                      }else{
                          
                          _cancelUpLoad = NO;
                          NSLog(@"视频上传失败");
                          _showProgressView.hidden = YES;
                          [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                          [SVProgressHUD showErrorWithStatus:@"上传失败"];
                          [SVProgressHUD dismissWithDelay:2];
                      }
                      
                  } option:opt];

    } else {
        [self cell:cell clickedEditButton:nil];
        
    }

}
-(void)createLsyProgressVC{
    _showProgressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _showProgressView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
//    _showProgressView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_showProgressView];
    _showProgressView.hidden = YES;
    
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
//普通上传
-(void)createMediaUpLoadWithDataVideoDict:(NSDictionary *)dataVideoDict AndDataImageDict:(NSDictionary *)dataIamgeVideoDict AndVideoData:(NSData *)videoData AndImageData:(NSData *)imageData{
    [self addTapThing];
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
//    NSLog(@"视频地址%@",model.videoUrl);
//    NSData * videoData = [NSData dataWithContentsOfURL:model.videoUrl];
//    NSData * imageData= UIImageJPEGRepresentation(self.uploadModel.videoCoverImage, 0.1);
    
    //进度
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _LsyProgressView.progress = percent/1.25;
            
        });
        
    } params:dataVideoDict checkCrc:NO cancellationSignal:^BOOL{
        return _cancelUpLoad;
    }];
    
    [upManager putData:videoData key:nil token:_qiNiuToken
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  //                  NSLog(@"info的内容：%@", info);
                  //                  NSLog(@"resp内容：%@", resp);
                  
                  if (!info.error) {
                      
                      //进度
                      QNUploadOption *opt1 = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              _LsyProgressView.progress = percent/5+0.8;
                          });
                      } params:dataVideoDict checkCrc:NO cancellationSignal:nil];
                      [upManager putData:imageData key:nil token:_qiNiuToken
                                complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                    NSLog(@"info第二的内容：%@", info);
                                    NSLog(@"resp第二内容：%@", resp);
                                    if (!info.error) {
                                        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                        [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                                        [SVProgressHUD dismissWithDelay:3];
                                        _showProgressView.hidden = YES;

                                    }else{
                                        _cancelUpLoad = NO;
                                        NSLog(@"图片上传失败");
                                        _showProgressView.hidden = YES;
                                        
                                    }
                                } option:opt1];
                  }else{

                      _cancelUpLoad = NO;
                      NSLog(@"视频上传失败");
                      _showProgressView.hidden = YES;
                      [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                      [SVProgressHUD showErrorWithStatus:@"上传失败"];
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
@end
