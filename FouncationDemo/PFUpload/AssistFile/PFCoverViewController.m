//
//  PFCoverViewController.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/28.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFCoverViewController.h"

#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>

#define SUB_VIEW_SIDE (SCREEN_WIDTH - 30) / 7.f

@interface PFCoverViewController ()

@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UIImageView *slideImageView;

@end

@implementation PFCoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更换封面";
    self.view.backgroundColor = [UIColor colorWithRed:40/255.0 green:39/255.0 blue:49/255.0 alpha:1];
    
    self.showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64 - 64 * _offset, SCREEN_WIDTH, SCREEN_WIDTH)];
    [self.view addSubview:_showImageView];
    

    for (NSInteger i = 0; i < 7; i ++) {
        UIImageView *subImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + SUB_VIEW_SIDE * i, SCREEN_HEIGHT - SUB_VIEW_SIDE * 2 - 15 - 64 * _offset, SUB_VIEW_SIDE, SUB_VIEW_SIDE)];
        [subImageView setImage:_subImages[i]];
        [self.view addSubview:subImageView];
    }
    
    self.slideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT - SUB_VIEW_SIDE * 2 - 18 - 64 * _offset, SUB_VIEW_SIDE + 6, SUB_VIEW_SIDE + 6)];
    self.slideImageView.layer.borderWidth = 3;
    self.slideImageView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.slideImageView.userInteractionEnabled = YES;
    [self.view addSubview:_slideImageView];
    
    [self getVideoImageOfPercent:0];
    
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SUB_VIEW_SIDE * 2 - 15 - 35 - 64 * _offset, SCREEN_WIDTH, 20)];
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.textColor = [UIColor whiteColor];
    noticeLabel.text = @"滑动图片选择1帧作为封面";
    [self.view addSubview:noticeLabel];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirm {
    if (self.didSelectCoverBlock) {
        self.didSelectCoverBlock(self.showImageView.image);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getVideoImageOfPercent:(CGFloat)percent {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_videoUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    
    CMTime videoTime = asset.duration;
    CGFloat videoSeconds = CMTimeGetSeconds(videoTime);
    
    percent = MIN(0.99, MAX(0.01, percent));
    CMTime thumbTime = CMTimeMakeWithSeconds(videoSeconds * percent, 600);
    CGImageRef image = [generator copyCGImageAtTime:thumbTime actualTime:nil error:nil];
    UIImage *showImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    [self.showImageView setImage:showImage];
    [self.slideImageView setImage:showImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (CGRectContainsPoint(_slideImageView.frame, [touch locationInView:self.view])) {
        return;
    }
    if (CGRectContainsPoint(CGRectMake(15, SCREEN_HEIGHT - SUB_VIEW_SIDE * 2 - 15 - 64 * _offset, SUB_VIEW_SIDE * 7, SUB_VIEW_SIDE), [touch locationInView:self.view])) {
        CGFloat positionX = [touch locationInView:self.view].x;
        positionX = MIN(SCREEN_WIDTH - 15 - SUB_VIEW_SIDE/2, MAX(positionX, 15 + SUB_VIEW_SIDE/2));
        self.slideImageView.center = CGPointMake(positionX, _slideImageView.center.y);
        [self getVideoImageOfPercent:(positionX - 15 - SUB_VIEW_SIDE/2) / (SCREEN_WIDTH - 30 - SUB_VIEW_SIDE)];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (CGRectContainsPoint(_slideImageView.frame, [touch locationInView:self.view])) {
        CGFloat positionX = [touch locationInView:self.view].x;
        positionX = MIN(SCREEN_WIDTH - 15 - SUB_VIEW_SIDE/2, MAX(positionX, 15 + SUB_VIEW_SIDE/2));
        self.slideImageView.center = CGPointMake(positionX, _slideImageView.center.y);
        [self getVideoImageOfPercent:(positionX - 15 - SUB_VIEW_SIDE/2) / (SCREEN_WIDTH - 30 - SUB_VIEW_SIDE)];
    }
}

@end
