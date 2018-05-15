/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	View controller containing a player view and basic playback controls.
*/

#import <UIKit/UIKit.h>


@class AAPLPlayerView;

@interface AAPLPlayerViewController : UIViewController

@property (readonly) AVPlayer *player;
@property (nonatomic, strong)AVURLAsset *asset;//AVAsset的子类，根据url来初始化，用来生成缩略图

@property CMTime currentTime;
@property (readonly) CMTime duration;
@property float rate;

@property (weak) IBOutlet UISlider *timeSlider;
@property (weak) IBOutlet UILabel *startTimeLabel;
@property (weak) IBOutlet UILabel *durationLabel;
@property (weak) IBOutlet UIButton *playPauseButton;
@property (weak) IBOutlet AAPLPlayerView *playerView;

@property (weak) IBOutlet UIButton *rewindButton;
@property (weak) IBOutlet UIButton *fastForwardButton;

@end

