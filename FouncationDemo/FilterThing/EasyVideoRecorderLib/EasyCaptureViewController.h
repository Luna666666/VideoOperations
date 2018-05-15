

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^CapturedVideoOutputCallback)(NSURL *exportUrl, NSInteger error);

@interface EasyCaptureViewController : UIViewController 

@property (nonatomic, copy)CapturedVideoOutputCallback outputCallback;
@property (nonatomic)CGFloat minDuration;
@property (nonatomic)CGFloat maxDuration;

@end

