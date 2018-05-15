//
//  VideoUploaderMainViewController.m
//  ManufacturingAlliance
//
//  Created by swkj on 16/11/29.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "VideoUploaderMainViewController.h"
#import "EasyCaptureViewController.h"
#import "CustomVideoEditorController.h"
#import "AAPLPlayerViewController.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface VideoUploaderMainViewController ()<CustomVideoEditorDelegate,TZImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *takingPhotoUploader;

@property (weak, nonatomic) IBOutlet UIButton *generalUploader;

@property (weak, nonatomic) IBOutlet UIButton *highQualityUploader;


@end

@implementation VideoUploaderMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"视频上传demo";
   
    
    
}

- (IBAction)takingPhoto:(id)sender {
    NSLog(@"the button of taking photoes is pressed!");
      __weak typeof (self) weakSelf = self;
        __strong typeof(self) strongSelf = weakSelf;
    //授权音频视频开放权限
    if ([self canMicrophon]&&[self canOpenrecode]) {
        [strongSelf createCaptureVC];
    }
    
}
- (IBAction)generalUploader:(id)sender {
      __weak typeof (self) weakSelf = self;
      __strong typeof(self) strongSelf = weakSelf;
    //上传视频
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 Quailty:NO  delegate:strongSelf];
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.allowPickingVideo = YES;
    [strongSelf presentViewController:imagePickerVc animated:YES completion:nil];
    NSLog(@"general uploader button is pressed!");
}

- (IBAction)highUploaderbuttonispressed:(id)sender {
    NSLog(@"highuploader is pressed!");
}
-(BOOL)canOpenrecode{
    
    
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        //无权限
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有权限获取摄像头，请到设置中开启" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)canMicrophon
{
    __block BOOL bCanRecord = YES;
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                // Microphone enabled code
                NSLog(@"Microphone is enabled..");
                bCanRecord = YES;
            }
            else {
                // Microphone disabled code
                NSLog(@"Microphone is disabled..");
                bCanRecord = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"麦克风没有开启"
                                                message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克"
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil]  show];
                });
            }
        }];
        
    }    return bCanRecord;
}

//拍摄类
-(void)createCaptureVC{
    //视频拍摄控制器
    EasyCaptureViewController * easyCaptureVC = [[EasyCaptureViewController alloc]init];
    easyCaptureVC.minDuration = 3.0;
    easyCaptureVC.maxDuration = 90;
    UINavigationController *navCaptrue = [[UINavigationController alloc] initWithRootViewController:easyCaptureVC];
    [self presentViewController:navCaptrue animated:YES completion:nil];
    __weak typeof (self) weakSelf = self;
    easyCaptureVC.outputCallback = ^(NSURL *exportPath, NSInteger error){
        
        __strong typeof(self) strongSelf = weakSelf;
        //前后摄像头，曝光，暂停，播放控制器,点击确定后回调产生导出路径
        CustomVideoEditorController *playController = [[CustomVideoEditorController alloc] initWithVideoFileURL:exportPath delegate:strongSelf];
        dispatch_async(dispatch_get_main_queue(), ^{
            [navCaptrue pushViewController:playController animated:YES];
           
        });
        playController.outputCallback = ^(NSString *exportPath, NSInteger error){
            
            //exportPath 拍摄导出的视频的地址
            if (error == 0)
            {
                //视频编辑控制器,美颜，MV等
                AAPLPlayerViewController *captureViewCon = [[AAPLPlayerViewController alloc] initWithNibName:@"AAPLPlayerViewController" bundle:nil];
                //通过导出的视频路径初始化url，进而再通过url获取缩略图
                captureViewCon.asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:exportPath]];
                
                [navCaptrue pushViewController:captureViewCon animated:YES];
                
            }
        };
        ////刷新数据源,可以刷新音乐，mv特效, 相框,从资源文件加载视频，图片，指定名称（去除扩展名）和路径添加到数组即可
        [playController reloadEffects:[self localTestMusic]];
        [playController reloadEffects:[self localTestFxMov]];
        [playController reloadEffects:[self localTestPicFrame]];
        
        
        
    };
    
}
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
#pragma mark CustomVideoEditorDelegate

- (void)willShowMoreMusicView:(EasyVideoEditorController *)editor
{
    
}

- (void)willShowMoreFxMovView:(EasyVideoEditorController *)editor
{
    
}

- (void)willShowMorePicFrameView:(EasyVideoEditorController *)editor
{
    
}


@end
