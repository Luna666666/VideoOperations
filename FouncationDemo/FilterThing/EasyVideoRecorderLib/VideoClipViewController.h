/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	View controller containing a player view and basic playback controls.
*/

#import <UIKit/UIKit.h>


@class AAPLPlayerView;

@interface VideoClipViewController : UIViewController

@property (readonly) AVPlayer *player;
@property (nonatomic, strong)AVAsset *asset;

@property CMTime currentTime;
@property (readonly) CMTime duration;
@property float rate;

@property (nonatomic, strong) UISlider *timeSlider;
@property (nonatomic, strong) UILabel *startTimeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) AAPLPlayerView *playerView;


@property (nonatomic, assign) CMTime clipStart;
@property (nonatomic, assign) CMTime clipDuration;
@property (nonatomic, assign) BOOL videoStydle;//风格

@property (nonatomic, copy)void (^ApplyTrim)(CMTime clipStart, CMTime clipDuration,BOOL stydle);
- (IBAction)goBack:(id)sender;

- (id)initWithStart:(CMTime)startTime duration:(CMTime)duration asset:(AVAsset *)asset;

@end

