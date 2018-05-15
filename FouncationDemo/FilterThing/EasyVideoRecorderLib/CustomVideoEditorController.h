//
//  CustomVideoEditorController.h
//  EasyVideoRecorder
//
//  Created by tsinglink on 16/3/21.
//  Copyright © 2016年 EasyDarwin. All rights reserved.
//

#import "EasyVideoEditorController.h"

@protocol CustomVideoEditorDelegate;

@interface CustomVideoEditorController : EasyVideoEditorController
@property (nonatomic,assign)BOOL videoStydle;
- (id)initWithVideoFileURL:(NSURL *)videoFileURL delegate:(id<CustomVideoEditorDelegate>)delegate;
//- (id)initWithVideoSegment:(SCRecordSegment *)segment delegate:(id<CustomVideoEditorDelegate>)delegate;
- (id)initWithVideoSegment:(SCRecordSegment *)segment Stydle:(BOOL)stydle delegate:(id<CustomVideoEditorDelegate>)delegate;
//刷新数据源,可以刷新音乐，mv特效, 相框
- (NSInteger)reloadEffects:(NSArray <__kindof EffectInfo *> *)effcts;

// 强制应用某个特效，比如下载某个特效想立即生效，可以在reloadEffects后调用该方法。但是一定
// 要保证effect数据源已经存在
- (void)applyEffect:(EffectInfo *)effect;
@end

@protocol CustomVideoEditorDelegate<NSObject>

@optional

// 点击更多产生的回调，可以在回调中显示下载页面。再调用reloadEffects刷新数据源。
- (void)willShowMoreMusicView:(EasyVideoEditorController *)editor;
- (void)willShowMoreFxMovView:(EasyVideoEditorController *)editor;
- (void)willShowMorePicFrameView:(EasyVideoEditorController *)editor;
@end
