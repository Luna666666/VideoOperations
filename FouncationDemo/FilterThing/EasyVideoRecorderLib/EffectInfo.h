//
//  EffectInfo.h
//  EasyVideoRecorder
//
//  Created by tsinglink on 16/3/22.
//  Copyright © 2016年 EasyDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
    EffectTypeFilter,
    EffectTypeFxMv,
    EffectTypePicFrame,
    EffectTypeMusic,
}IEffectType;

typedef enum
{
    Blend_Sceen,    // mv透明效果
    Blend_ColorKey, // mv非透明效果
    Blend_Normal,
}IBlendMode;

@interface EffectInfo : NSObject

@property (nonatomic) IEffectType type;
@property (nonatomic)NSInteger effectID; // 0表示原画质 无效果
@property (nonatomic, copy)NSString *name;
@property (nonatomic, strong)NSString *thumbnailPath;

@end

@interface FxMovEffect : EffectInfo

@property (nonatomic, copy)NSString *videoPath;
@property (nonatomic, copy)NSString *audioTrackPath;
@property (nonatomic)IBlendMode blendMode;
@end

@interface PicFrameEffect : EffectInfo

//序列图片。因为相框和mv序列帧都是用PicFrameEffect实现，所以要根据基类成员变量type来决定特效类型。
// 默认为相框特效。指定type为EffectTypeFxMv时表示mv序列帧。
@property (nonatomic, strong)NSArray *seqFramePaths;

@property (nonatomic)NSTimeInterval animateDuration;

// 0 表示无限循环
@property (nonatomic)NSInteger loopCount;

@property (nonatomic, copy)NSString *audioTrackPath;
@end

@interface FilterEffect : EffectInfo

@end

@interface MusicEffect : EffectInfo
@property (nonatomic, copy)NSString *localPath;
@end