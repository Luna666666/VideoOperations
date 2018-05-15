//
//  DNQUploaderViewController.h
//  ManufacturingAlliance
//
//  Created by swkj on 16/11/29.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNQUploaderViewController : UIViewController
//  -------  视频url，类型为NSURL
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) id videoAsset;

@property (nonatomic,assign) BOOL HigeQuality;
@property (nonatomic,assign) BOOL choseMedial;
@end
