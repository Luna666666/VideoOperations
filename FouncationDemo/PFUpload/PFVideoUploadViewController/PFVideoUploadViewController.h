//
//  VideoUploadViewController.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/23.
//  Copyright © 2016年 thidnet. All rights reserved.
//

//  -------  选择视频/视频上传定价  -------

#import <UIKit/UIKit.h>
#import "PFUploadModel.h"

@interface PFVideoUploadViewController : UIViewController
@property (nonatomic,assign) BOOL HigeQuality;
@property (nonatomic,assign) BOOL choseMedial;


//  -------  视频url，类型为NSURL
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) id videoAsset;
//  -------  草稿箱界面编辑时需要的信息，请忽略
@property (nonatomic, strong) PFUploadModel *uploadModel;
@property (nonatomic, copy) void (^didEditBlock)(PFUploadModel *);
@property (nonatomic, copy) void (^didUploadBlock)();

@end
