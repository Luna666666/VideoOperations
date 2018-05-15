//
//  PFDraftViewController.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/30.
//  Copyright © 2016年 thidnet. All rights reserved.
//

//  -------  草稿箱  -------

#import <UIKit/UIKit.h>

@interface PFDraftViewController : UIViewController

@property (nonatomic, copy) void (^draftDidChangeHandle)();

@end
