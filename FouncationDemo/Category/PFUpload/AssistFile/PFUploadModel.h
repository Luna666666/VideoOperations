//
//  PFUploadModel.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/29.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFUploadModel : NSObject

//  -------  封面图片
@property (nonatomic, strong) UIImage *videoCoverImage;

//  -------  视频Url
@property (nonatomic, strong) NSURL *videoUrl;

//  -------  作品描述
@property (nonatomic, strong) NSString *videoDescription;

//  -------  作品名称
@property (nonatomic, strong) NSString *videoName;

//  -------  作品类型
@property (nonatomic, assign) NSInteger videoType;
@property (nonatomic, strong) NSString *videoTypeStr;

//  -------  作品小类
@property (nonatomic, assign) NSInteger videoSubType;
@property (nonatomic, strong) NSString *videoSubTypeStr;

//  -------  导演
@property (nonatomic, strong) NSString *videoDirection;

//  -------  编剧
@property (nonatomic, strong) NSString *videoWriter;

//  -------  演员
@property (nonatomic, strong) NSString *videoActor;

//  -------  作品在线观看价格
@property (nonatomic, strong) NSString *videoPrice;

//  -------  推广周期
@property (nonatomic, assign) NSInteger spreadCycle;
@property (nonatomic, strong) NSString *spreadCycleStr;

//  -------  一档  播放次数  奖励
@property (nonatomic, strong) NSString *video1SpreadTimes;
@property (nonatomic, strong) NSString *video1SpreadRewards;

//  -------  二档  播放次数  奖励
@property (nonatomic, strong) NSString *video2SpreadTimes;
@property (nonatomic, strong) NSString *video2SpreadRewards;

//  -------  三档  播放次数  奖励
@property (nonatomic, strong) NSString *video3SpreadTimes;
@property (nonatomic, strong) NSString *video3SpreadRewards;

//  -------  保存日期
@property (nonatomic, strong) NSString *videoDate;

- (NSString *)hasEmpty;

@end
