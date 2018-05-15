/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    View controller containing a player view and basic playback controls.
*/


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "AAPLPlayerViewController.h"
#import "AAPLPlayerView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SVProgressHUD.h"

#import "DNQUploaderViewController.h"
// Private properties
@interface AAPLPlayerViewController ()
{
    //播放器,本身不能播放视频，需借助AVPlayerlayer添加到相应视图图层上才可以
    AVPlayer *_player;
    id<NSObject> _timeObserverToken;
    //每个视频对应的视频资源和状态
    AVPlayerItem *_playerItem;
    
    BOOL dragToSlide;
}

@property AVPlayerItem *playerItem;

@property (readonly) AVPlayerLayer *playerLayer;//视频播放layer层

@end

@implementation AAPLPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //tableView在导航栏下面
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //设置导航栏左右按钮，左边返回，右边发布
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @ "EasyVideoResource" ofType :@ "bundle"];
    NSString *imgPath= [bundlePath stringByAppendingPathComponent :@"JFBackWhite.png"];
    UIImage *image=[UIImage imageWithContentsOfFile:imgPath];
    [back setImage:image forState:UIControlStateNormal];
 
    back.frame=CGRectMake(5,5,40,40);
    back.contentEdgeInsets = UIEdgeInsetsMake(0,-5, 0, 0);
    [back addTarget:self action:@selector(submitFeedBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem=backItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(uploadVideo:)];
}
// MARK: - View Handling

/*
	KVO context used to differentiate KVO callbacks for this class versus other
	classes in its class hierarchy.
*/
static int AAPLPlayerViewControllerKVOContext = 0;
//返回的时候把缩略图存本地目录
-(void)submitFeedBack{
    NSFileManager *manager = [NSFileManager defaultManager];
    //查找字符串
    NSRange range = [[self.asset.URL absoluteString] rangeOfString:@"tmp"];
    //substringFromIndex从索引至后进行截取
    NSString *realUrlStr = [[self.asset.URL absoluteString] substringFromIndex:range.location];
    NSString *urlStr = [NSHomeDirectory() stringByAppendingFormat:@"/%@", realUrlStr];
    if ([manager fileExistsAtPath:urlStr]) {
        [manager removeItemAtPath:urlStr error:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated {

self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.playPauseButton.hidden = YES;
    self.playerView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.playerView addGestureRecognizer:tapGesture];
    /*
        Update the UI when these player properties change.
    
        Use the context parameter to distinguish KVO for our particular observers and not
        those destined for a subclass that also happens to be observing these properties.
    */

    [self addObserver:self forKeyPath:@"player.currentItem.duration" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];

    //初始化视频播放对象
    self.playerView.playerLayer.player = self.player;
    //异步生成和播放视频缩略图
    [self asynchronouslyLoadURLAsset:self.asset];
    
    // Use a weak self variable to avoid a retain cycle in the block.
    AAPLPlayerViewController __weak *weakSelf = self;
    //视频播放器滑动时间显示设置,监听播放时间变化
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:
        ^(CMTime time) {
            //没有滑动滑动杠
            if (!dragToSlide)
            {
                weakSelf.timeSlider.value = CMTimeGetSeconds(time);
                
                double newDurationSeconds = CMTimeGetSeconds(time);
                int wholeMinutes = (int)trunc(newDurationSeconds / 60);
                //显示开始时间，分秒,及异步播放时的时间
                self.startTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, (int)trunc(newDurationSeconds) - wholeMinutes * 60];
            }

        }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//返回的时候移除时间监听
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
//页面消失的时候视频暂停播放
    [self.player pause];

    [self removeObserver:self forKeyPath:@"player.currentItem.duration" context:&AAPLPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.rate" context:&AAPLPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:&AAPLPlayerViewControllerKVOContext];
}
//点击发布按钮
- (IBAction)uploadVideo:(id)sender
{
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    
//    UIStoryboard *upload = [UIStoryboard storyboardWithName:@"PFVideoUpload" bundle:nil];
//    PFVideoUploadViewController *vc = [upload instantiateInitialViewController];
//    vc.videoUrl = self.asset.URL;//传入视频缩略图资源到发布界面，普通上传
//    vc.choseMedial = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//    [library writeVideoAtPathToSavedPhotosAlbum:self.asset.URL
//                                completionBlock:^(NSURL *assetURL, NSError *error)
//     {
//         dispatch_async(dispatch_get_main_queue(), ^{
//             
//             
//             if (error)
//             {
//                 NSLog(@"fail to saved: %@", error);
//             }
//             else
//             {
//                 [SVProgressHUD showInfoWithStatus:@"成功保存到相册"];
//                 //进入发布界面
//                 [self.navigationController pushViewController:[XXViewController new ] animated:YES];
//                 NSLog(@"writeToAlbum complete %@",self.asset.URL);
//             }
//         });
//         
//     }];
    
    DNQUploaderViewController *dnqVC=[[DNQUploaderViewController alloc]init];
    dnqVC.videoUrl=self.asset.URL;
    dnqVC.choseMedial=YES;
    [self.navigationController pushViewController:dnqVC animated:YES];
    
}


// MARK: - Properties

// Will attempt load and test these asset keys before playing
+ (NSArray *)assetKeysRequiredToPlay {
    return @[ @"playable", @"hasProtectedContent" ];
}
//初始化播放器对象
- (AVPlayer *)player {
    if (!_player)
        _player = [[AVPlayer alloc] init];
    return _player;
}
//返回视频播放当前时间
- (CMTime)currentTime
{
    return self.player.currentTime;
}
//重设当前播放时间
- (void)setCurrentTime:(CMTime)newCurrentTime
{
    [self.player seekToTime:newCurrentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
//返回视频播放持续时间
- (CMTime)duration {
    return self.player.currentItem ? self.player.currentItem.duration : kCMTimeZero;
}
//返回暂停是否，1.0代表正常播放
- (float)rate {
    return self.player.rate;
}
- (void)setRate:(float)newRate {
    self.player.rate = newRate;
}
//初始化视频播放图层
- (AVPlayerLayer *)playerLayer {
    return self.playerView.playerLayer;
}
//初始化当前视频资源和状态
- (AVPlayerItem *)playerItem {
    return _playerItem;
}
//重设当前视频播放资源和状态
- (void)setPlayerItem:(AVPlayerItem *)newPlayerItem {
    if (_playerItem != newPlayerItem) {

        _playerItem = newPlayerItem;
    
        // If needed, configure player item here before associating it with a player
        // (example: adding outputs, setting text style rules, selecting media options)
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

// MARK: - Asset Loading
//加载视频播放缩略图，AVURLAsset是AVASset的子类，听过url初始化，而AVPlayItem（视频播放资源和状态）通过AVURLAsser初始化，调用播放器即可播放缩略图
- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset {

    /*
        Using AVAsset now runs the risk of blocking the current thread
        (the main UI thread) whilst I/O happens to populate the
        properties. It's prudent to defer our work until the properties
        we need have been loaded.
    */
    [newAsset loadValuesAsynchronouslyForKeys:AAPLPlayerViewController.assetKeysRequiredToPlay completionHandler:^{

        /*
            The asset invokes its completion handler on an arbitrary queue.
            To avoid multiple threads using our internal state at the same time
            we'll elect to use the main thread at all times, let's dispatch
            our handler to the main queue.
        */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (newAsset != self.asset) {
                /*
                    self.asset has already changed! No point continuing because
                    another newAsset will come along in a moment.
                */
                return;
            }
        
            /*
                Test whether the values of each of the keys we need have been
                successfully loaded.
            */
            for (NSString *key in self.class.assetKeysRequiredToPlay) {
                NSError *error = nil;
                if ([newAsset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {

                    NSString *message = [NSString localizedStringWithFormat:NSLocalizedString(@"error.asset_key_%@_failed.description", @"Can't use this AVAsset because one of it's keys failed to load"), key];

                    [self handleErrorWithMessage:message error:error];

                    return;
                }
            }

            // We can't play this asset.
            if (!newAsset.playable || newAsset.hasProtectedContent) {
                NSString *message = NSLocalizedString(@"error.asset_not_playable.description", @"Can't use this AVAsset because it isn't playable or has protected content");

                [self handleErrorWithMessage:message error:nil];

                return;
            }

            /*
                We can play this asset. Create a new AVPlayerItem and make it
                our player's current item.
            */
            self.playerItem = [AVPlayerItem playerItemWithAsset:newAsset];
            [self.player play];
        });
    }];
}

// MARK: - IBActions

- (IBAction)playPauseButtonWasPressed:(UIButton *)sender {
    if (self.player.rate != 1.0)
    {
        // not playing foward so play
        if (CMTIME_COMPARE_INLINE(self.currentTime, ==, self.duration)) {
            // at end so got back to begining
            self.currentTime = kCMTimeZero;
        }
        [self.player play];
        self.playPauseButton.hidden = YES;
    }
    else
    {
        //自然播放的情况下允许暂停按钮显示，除此以外不显示
        // playing so pause
        self.playPauseButton.hidden = NO;
        [self.player pause];
    }
}
//点击视频播放图层暂停或回复暂停
- (void)tapGestureAction:(UITapGestureRecognizer *)gestureRecognizer
{
    [self playPauseButtonWasPressed:nil];
}
//视频后退
- (IBAction)rewindButtonWasPressed:(UIButton *)sender {
    self.rate = MAX(self.player.rate - 2.0, -2.0); // rewind no faster than -2.0
}
//视频前进
- (IBAction)fastForwardButtonWasPressed:(UIButton *)sender {
    self.rate = MIN(self.player.rate + 2.0, 2.0); // fast forward no faster than 2.0
}
//拖动滑动杠
- (IBAction)touchOnSlider:(id)sender
{
    dragToSlide = YES;
}
//当进度条拖动的时候重设当前时间
- (IBAction)timeSliderDidChange:(UISlider *)sender {
    self.currentTime = CMTimeMakeWithSeconds(sender.value, 1000);
    
    double newDurationSeconds = CMTimeGetSeconds(self.currentTime);
    int wholeMinutes = (int)trunc(newDurationSeconds / 60);
    self.startTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, (int)trunc(newDurationSeconds) - wholeMinutes * 60];
}

- (IBAction)touchCancelSlider:(id)sender
{
    dragToSlide = NO;
}

// MARK: - KV Observation
//当当前视频播放对象资源或者状态发生变化的时候更新UI.监听视频播放对象某个属性变化
// Update our UI when player or player.currentItem changes
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (context != &AAPLPlayerViewControllerKVOContext) {
        // KVO isn't for us.
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
//持续时间发生变化
    if ([keyPath isEqualToString:@"player.currentItem.duration"]) {

        // Update timeSlider and enable/disable controls when duration > 0.0

        // Handle NSNull value for NSKeyValueChangeNewKey, i.e. when player.currentItem is nil
        NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;

        self.timeSlider.maximumValue = newDurationSeconds;
        self.timeSlider.value = hasValidDuration ? CMTimeGetSeconds(self.currentTime) : 0.0;
        self.rewindButton.enabled = hasValidDuration;
        self.playPauseButton.enabled = hasValidDuration;
        self.fastForwardButton.enabled = hasValidDuration;
        self.timeSlider.enabled = hasValidDuration;
        self.startTimeLabel.enabled = hasValidDuration;
        self.durationLabel.enabled = hasValidDuration;
        int wholeMinutes = (int)trunc(newDurationSeconds / 60);
        self.durationLabel.text = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, (int)trunc(newDurationSeconds) - wholeMinutes * 60];

    }
    //跟新播放暂停状态
    else if ([keyPath isEqualToString:@"player.rate"]) {
        // Update playPauseButton image

        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
//        UIImage *buttonImage = (newRate == 1.0) ? [UIImage imageNamed:@"PauseButton"] : [UIImage imageNamed:@"PlayButton"];
//        [self.playPauseButton setImage:buttonImage forState:UIControlStateNormal];

        self.playPauseButton.hidden = (newRate == 1.0);
    }
    else if ([keyPath isEqualToString:@"player.currentItem.status"]) {
        // Display an error if status becomes Failed

        // Handle NSNull value for NSKeyValueChangeNewKey, i.e. when player.currentItem is nil
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            [self handleErrorWithMessage:self.player.currentItem.error.localizedDescription error:self.player.currentItem.error];
        }

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// Trigger KVO for anyone observing our properties affected by player and player.currentItem
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"duration"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.duration" ]];
    } else if ([key isEqualToString:@"currentTime"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.currentTime" ]];
    } else if ([key isEqualToString:@"rate"]) {
        return [NSSet setWithArray:@[ @"player.rate" ]];
    } else {
        return [super keyPathsForValuesAffectingValueForKey:key];
    }
}

// MARK: - Error Handling

- (void)handleErrorWithMessage:(NSString *)message error:(NSError *)error {
    NSLog(@"Error occured with message: %@, error: %@.", message, error);

    NSString *alertTitle = NSLocalizedString(@"alert.error.title", @"Alert title for errors");
    NSString *defaultAlertMesssage = NSLocalizedString(@"error.default.description", @"Default error message when no NSError provided");
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:alertTitle message:message ?: defaultAlertMesssage preferredStyle:UIAlertControllerStyleAlert];

    NSString *alertActionTitle = NSLocalizedString(@"alert.error.actions.OK", @"OK on error alert");
    UIAlertAction *action = [UIAlertAction actionWithTitle:alertActionTitle style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];

    [self presentViewController:controller animated:YES completion:nil];
}

@end
