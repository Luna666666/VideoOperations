//
//  PFCoverViewController.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/28.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFCoverViewController : UIViewController

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) NSArray *subImages;
@property (nonatomic, copy) void (^didSelectCoverBlock)(UIImage *);

@end
