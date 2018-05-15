//
//  TZVideoPlayerController.m
//  TZImagePickerController
//
//  Created by 谭真 on 16/1/5.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import "TZVideoPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "TZAssetModel.h"
#import "TZImagePickerController.h"
#import "TZPhotoPreviewController.h"
#import "CustomVideoEditorController.h"
#import "AAPLPlayerViewController.h"
#import "XSInfoView.h"
#import "MBProgressHUD.h"
#import "VideoClipViewController.h"
#import "SCRecordSegment.h"
#import "LsyRmoveVideo.h"
#import "DNQUploaderViewController.h"
@interface TZVideoPlayerController ()<CustomVideoEditorDelegate> {
    AVPlayer *_player;
    UIButton *_playButton;
    UIImage *_cover;
    
    UIView *_toolBar;
    UIButton *_okButton;
    UIProgressView *_progress;
    MBProgressHUD * HUD;
    NSString * _urlString;
}
@end

@implementation TZVideoPlayerController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
   
}

-(void)disapperSelf:(NSNotification *)notic{
    NSString * str = (NSString *)[notic object];
    if ([str isEqualToString:@"dealloc"]) {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
         [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = [NSBundle tz_localizedStringForKey:@"Preview"];
    [self configMoviePlayer];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disapperSelf:) name:@"Lsy_dealloc" object:nil];

    
//    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];

}

- (void)configMoviePlayer {
    [[TZImageManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        _cover = photo;
    }];
    [[TZImageManager manager] getVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _player = [AVPlayer playerWithPlayerItem:playerItem];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            playerLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:playerLayer];
            //设置视频播放进度
            [self addProgressObserver];
            //配置播放暂停按钮的UI
            [self configPlayButton];
            //配置底部导航条及OK按钮
            [self configBottomToolBar];
            //视频播放到最后的监听
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        });
    }];
}

/// Show progress，do it next time / 给播放器添加进度更新,下次加上
- (void)addProgressObserver{
    AVPlayerItem *playerItem = _player.currentItem;
    UIProgressView *progress = _progress;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([playerItem duration]);
        if (current) {
            [progress setProgress:(current/total) animated:YES];
        }
    }];
}

- (void)configPlayButton {
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake(0, 64, self.view.tz_width, self.view.tz_height - 64 - 44);
    [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay.png"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlayHL.png"] forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.tz_height - 44, self.view.tz_width, 44)];
    CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    _toolBar.alpha = 0.7;
    
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(self.view.tz_width - 44 - 12, 0, 44, 44);
    _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setTitle:[NSBundle tz_localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    [_okButton setTitleColor:imagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
    
    [_toolBar addSubview:_okButton];
    [self.view addSubview:_toolBar];
}

#pragma mark - Click Event

- (void)playButtonClick {
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        [_player play];
        [self.navigationController setNavigationBarHidden:YES];
        _toolBar.hidden = YES;
        [_playButton setImage:nil forState:UIControlStateNormal];
        if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
    } else {
        [self pausePlayerAndShowNaviBar];
    }
}
#pragma mark-点击拍摄完视频后的done按钮
- (void)okButtonClick {
     HUD = [[MBProgressHUD alloc] initWithView:self.view];
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
   [self.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"读取中";
    [HUD show:YES];
    //导出视频路径发通知
    [[TZImageManager manager] getVideoOutputPathWithAsset:_model.asset completion:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        __weak typeof (self) weakSelf = self;
        if (outputPath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //                        HUD.hidden = YES;
                //                        XSInfoViewStyle *style = [[XSInfoViewStyle alloc] init];
                //                        style.info = @"压缩成功";
                //                        style.layoutStyle = XSInfoViewLayoutStyleVertical;
                //                        [XSInfoView showInfoWithStyle:style onView:[UIApplication sharedApplication].keyWindow];
                //                        [self createEditorVC:outputPath];
            });
            
        }
        
    }];
    
    //从本地相册选择一个视频后的代理回调,传一个UIImage和ALAsset类型即可
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingVideo:sourceAssets:)]) {
        [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingVideo:_cover sourceAssets:_model.asset];
    }
    //用户选择视频handle会回调
    if (imagePickerVc.didFinishPickingVideoHandle) {
        imagePickerVc.didFinishPickingVideoHandle(_cover,_model.asset);
    }
    if (self.navigationController) {
        NSLog(@"ahuahuahuah");
        if (imagePickerVc.autoDismiss) {
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//解开这个直接返回
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUrl:) name:@"video_url" object:nil];
           
           
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark-点击down按钮选择视频后最终回调的一个视频url
-(void)getUrl:(NSNotification *)noti{
    NSLog(@"为什么这么多次");
//    static dispatch_once_t onceToken;
    
//    dispatch_once(&onceToken, ^{
    _urlString = (NSString *)[noti object];
//    });
    
    if (_urlString) {
        HUD.hidden = YES;
        //高清上传
        if ([TZImageManager manager].uploadHighQuality) {
            NSLog(@"开始高清上传 %@",_urlString);
            DNQUploaderViewController *vc = [[DNQUploaderViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
            vc.videoUrl = [NSURL fileURLWithPath:_urlString];
            vc.videoAsset = _model.asset;
            vc.HigeQuality = YES;
            //删除沙盒里视频
            [self.navigationController pushViewController:vc animated:YES];
        }else{
       //普通上传
          [self showClipView:_urlString];
        //删除沙盒里视频
        [LsyRmoveVideo LsyRmoveVideo:[NSURL fileURLWithPath:_urlString]];
            
        }
    }


}
//视频剪切,给一个视频裁剪的起始时间和持续时间和视频资源即可
- (void)showClipView:(NSString *)outputPath
{
    AVAsset *avAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:outputPath]];
    
    VideoClipViewController *clipViewController = [[VideoClipViewController alloc] initWithStart:kCMTimeZero
                                                                                        duration:[(AVURLAsset *)avAsset duration]
                                                                                           asset:(AVURLAsset *)avAsset];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:clipViewController];
    [self presentViewController:nav animated:YES completion:^{
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disapperSelf:) name:@"Lsy_dealloc" object:nil];
    }];
    
    
    clipViewController.ApplyTrim = ^(CMTime start, CMTime duraiton,BOOL stydle){
        
        SCRecordSegment *segment = [[SCRecordSegment alloc] initWithAsset:avAsset];
        segment.clipStartTime = start;
        segment.clipDuration = duraiton;
        //视频裁剪完后进入视频编辑页面,此后这块和拍摄上传过程一样
        CustomVideoEditorController *playController = [[CustomVideoEditorController alloc] initWithVideoSegment:segment Stydle:stydle delegate:self ];
        playController.videoStydle = stydle;
        playController.outputCallback = ^(NSString *exportPath, NSInteger error){
            //exportPath 视频的地址
            if (error == 0)
            {
                //如果导出没有错误拿到视频资源就可以播放，快进或者后退
                //                        [weakSelf previewVideo:exportPath];
                AAPLPlayerViewController *captureViewCon = [[AAPLPlayerViewController alloc] initWithNibName:@"AAPLPlayerViewController" bundle:nil];
                captureViewCon.asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:exportPath]];
                [nav pushViewController:captureViewCon animated:YES];
                
            }
        };
        //视频处理，美颜，滤镜，MV
        [playController reloadEffects:[self localTestMusic]];
        [playController reloadEffects:[self localTestFxMov]];
        [playController reloadEffects:[self localTestPicFrame]];
        [nav pushViewController:playController animated:YES];
    };
}

//编辑类代理方法
-(void)createEditorVC:(NSString *)outPutPath Start:(CMTime) start Duration:(CMTime) duration Stydle:(BOOL) stydle{
    
    CustomVideoEditorController *playController = [[CustomVideoEditorController alloc] initWithVideoFileURL:[NSURL fileURLWithPath:outPutPath] delegate:self];
  
    playController.videoStydle = stydle;

    [self.navigationController pushViewController:playController animated:YES];
    playController.outputCallback = ^(NSString *exportPath, NSInteger error){
    
        if (error == 0)
        {
            //                        [weakSelf previewVideo:exportPath];
            AAPLPlayerViewController *captureViewCon = [[AAPLPlayerViewController alloc] initWithNibName:@"AAPLPlayerViewController" bundle:nil];
            captureViewCon.asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:exportPath]];
            
//            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:captureViewCon];
            [self.navigationController pushViewController:captureViewCon animated:YES];
            
        }
    };
    
    [playController reloadEffects:[self localTestMusic]];
    [playController reloadEffects:[self localTestFxMov]];
    [playController reloadEffects:[self localTestPicFrame]];
    
    
    
}

#pragma mark -------------编辑视频代理----------------------------------
#pragma mark testData
- (NSArray *)localTestMusic
{
    NSMutableArray *localCacheMusics = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mp3.bundle" ofType:nil];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (int i=0; i<[array count]; i++)
    {
        NSString *fileName = [array objectAtIndex:i];
        MusicEffect *music = [[MusicEffect alloc] init];
        music.effectID = i+1;
        music.name = [fileName stringByDeletingPathExtension];
        music.localPath = [path stringByAppendingPathComponent:fileName];
        [localCacheMusics addObject:music];
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"resource" ofType:nil];
    path = [path stringByAppendingPathComponent:@"testMov"];
    
    MusicEffect *music = [[MusicEffect alloc] init];
    music.name = @"sun";
    music.localPath = [path stringByAppendingPathComponent:@"2/sun.mp4"];;
    [localCacheMusics addObject:music];
    
    path = [[NSBundle mainBundle] pathForResource:@"resource" ofType:nil];
    path = [path stringByAppendingPathComponent:@"testMov"];
    
    MusicEffect *music2 = [[MusicEffect alloc] init];
    music2.name = @"sun2";
    music2.localPath = [path stringByAppendingPathComponent:@"2/sun2.mp4"];;
    [localCacheMusics addObject:music2];
    return localCacheMusics;
}

- (NSArray *)localTestPicFrame
{
    NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
    
    PicFrameEffect *pic = [[PicFrameEffect alloc] init];
    pic.name = @"原画质";
    pic.effectID = 0;
    [overlayArray addObject:pic];
    
    PicFrameEffect *pic1 = [[PicFrameEffect alloc] init];
    pic1.name = @"相框1";
    pic1.effectID = 1;
    
    pic1.thumbnailPath = [[NSBundle mainBundle] pathForResource:@"frame_1.png" ofType:nil];
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"frame_1.png" ofType:nil];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"frame_2.png" ofType:nil];
    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"frame_3.png" ofType:nil];
    
    pic1.seqFramePaths = [NSArray arrayWithObjects:path1, path2, path3, nil];
    pic1.animateDuration = 0.3;
    pic1.loopCount = 0;
    [overlayArray addObject:pic1];
    return overlayArray;
}

- (NSArray *)localTestFxMov
{
    NSDictionary *testDic = @{
                              @"1":@{@"name":@"时光", @"video":@"ssss.mp4", @"audio":@"dream.mp4"} ,
                              @"2":@{@"name":@"阳光", @"video":@"sun-480-480.mp4", @"audio":@"sun.mp4"} ,
                              @"3":@{@"name":@"地球", @"video":@"png05.mp4", @"audio":@"sun.mp4"} ,
                              @"9":@{@"name":@"电影", @"video":@"old-movie-2-480-480.mp4", @"audio":@"old-movie.mp4"} ,
                              @"10":@{@"name":@"雨天", @"video":@"rain-480-480.mp4", @"audio":@"rain.mp4"}
                              };
    NSMutableArray *localCacheMV = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"resource" ofType:nil];
    path = [path stringByAppendingPathComponent:@"testMov"];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    FxMovEffect *fxMov = [[FxMovEffect alloc] init];
    fxMov.name = @"原画质";
    fxMov.effectID = 0;
    [localCacheMV addObject:fxMov];
    
    {
        // 加测试序列帧，注意下面几个参数的设置
        PicFrameEffect *pic1 = [[PicFrameEffect alloc] init];
        pic1.name = @"序列帧";
        pic1.effectID = 4;
        pic1.thumbnailPath = [[NSBundle mainBundle] pathForResource:@"frame_1.png" ofType:nil];
        NSString *path1 = [[NSBundle mainBundle] pathForResource:@"frame_1.png" ofType:nil];
        NSString *path2 = [[NSBundle mainBundle] pathForResource:@"frame_2.png" ofType:nil];
        NSString *path3 = [[NSBundle mainBundle] pathForResource:@"frame_3.png" ofType:nil];
        pic1.seqFramePaths = [NSArray arrayWithObjects:path1, path2, path3, nil];
        pic1.animateDuration = 0.3;
        pic1.loopCount = 0;
        pic1.audioTrackPath = [path stringByAppendingPathComponent:@"2/sun.mp4"];
        // 序列帧时候一定要设置为EffectTypeFxMv
        pic1.type = EffectTypeFxMv;
        [localCacheMV addObject:pic1];
    }
    
    // 加载本地其他的mp4
    for (int i=0; i<[array count]; i++)
    {
        NSString *dirName = [array objectAtIndex:i];
        NSString *dirPath = [path stringByAppendingPathComponent:dirName];
        
        NSDictionary *contentDic = [testDic objectForKey:dirName];
        FxMovEffect *fxMov = [[FxMovEffect alloc] init];
        fxMov.name = [contentDic objectForKey:@"name"];
        fxMov.effectID = [dirName intValue];
        if ([dirName isEqualToString:@"3"])
        {
            // 不透明效果
            fxMov.blendMode = Blend_ColorKey;
        }
        else
        {
            fxMov.blendMode = Blend_Sceen;
        }
        
        // mv
        fxMov.videoPath = [dirPath stringByAppendingPathComponent:[contentDic objectForKey:@"video"]];
        fxMov.audioTrackPath = [dirPath stringByAppendingPathComponent:[contentDic objectForKey:@"audio"]];
        
        fxMov.thumbnailPath = [dirPath stringByAppendingPathComponent:@"icon.png"];
        
        [localCacheMV addObject:fxMov];
    }
    
    return localCacheMV;
}

#pragma mark - Notification Method

- (void)pausePlayerAndShowNaviBar {
    [_player pause];
    _toolBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay.png"] forState:UIControlStateNormal];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}


-(void)viewDidDisappear:(BOOL)animated{
//     [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"video_url" object:nil];
}
@end
