//
//  UIAlertController+supportedInterfaceOrientations.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/10/18.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "UIAlertController+supportedInterfaceOrientations.h"

@implementation UIAlertController (supportedInterfaceOrientations)

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
