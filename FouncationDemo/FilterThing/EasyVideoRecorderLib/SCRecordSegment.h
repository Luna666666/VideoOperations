//
//  SCRecordSegment.h
//  MyVideoEditor
//
//  Created by ChenShun on 16/5/28.
//  Copyright © 2016年 ChenShun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface SCRecordSegment : NSObject

@property (copy, nonatomic) NSURL *url;
@property (strong, nonatomic) AVAsset * asset;
@property (readonly, nonatomic) UIImage * thumbnail;

@property (readonly, nonatomic) UIImage * lastImage;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGRect renderRect;

@property (nonatomic, assign) CMTime startTime; // 全局时间标尺
@property (nonatomic, assign) CMTime endTime;

@property (nonatomic, assign) CMTime clipStartTime;// 自己的时间标尺
@property (nonatomic, assign) CMTime clipDuration;

// 在全局时间标尺中的位置
@property (nonatomic)CGFloat startX;
@property (nonatomic)CGFloat endX;

@property BOOL isPortrait;
/**
 The average frameRate of this segment
 */
@property (readonly, nonatomic) float frameRate;

/**
 Whether the file at the url exists
 */
@property (readonly, nonatomic) BOOL fileUrlExists;


- (instancetype)initWithAsset:(AVAsset *)asset;

@end
