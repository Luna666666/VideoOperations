//
#import <UIKit/UIKit.h>
#import "EffectInfo.h"
#import "SCRecordSegment.h"
typedef void(^EffectVideoOutputCallback)(NSString *exportPath, NSInteger error);

@interface EasyVideoEditorController : UIViewController
{
    UIView *preview;
    NSURL *curApplyMusicUrl;
}

// 是否显示播放进度 默认NO
@property BOOL showProgress;
@property (nonatomic, copy)EffectVideoOutputCallback outputCallback;
@property (nonatomic,assign)BOOL videoStydle;
@property (nonatomic, copy, readonly)NSURL *curApplyMusicUrl;
@property (strong, nonatomic, readonly) NSURL *videoFileURL;
@property (strong, nonatomic) SCRecordSegment * videoSegment;

- (id)initWithVideoFileURL:(NSURL *)videoFileURL;
- (id)initWithVideoSegment:(SCRecordSegment *)segment;

-(void)showClip;
- (void)stopAll;
- (void)restore;
@end
